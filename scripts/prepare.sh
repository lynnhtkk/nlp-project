#!/bin/bash

# Should be run from the root directory (BPC_NLP_PROJECT)
src=fi
tgt=en

# Setting paths variables 
# We assume, we run the script from root directory (BPC_NLP_PROJECT)
data_dir="data/preprocessed"
tools_dir="tools"
model_dir="models-common"
moses_scripts="$tools_dir/mosesdecoder/scripts"

# Set the name of your sample file
# We will use this to create .tok, .clean, and .tc files
prefix="train"

# Set max sentence length for cleaning
max_len=100

# 1. tokenization
for lang in $src $tgt; do
    input_file="$data_dir/$prefix.$lang"
    output_file="$data_dir/$prefix.tok.$lang"

    cat $input_file | \
    $moses_scripts/tokenizer/normalize-punctuation.perl -l $lang | \
    $moses_scripts/tokenizer/tokenizer.perl -a -l $lang \
    > $output_file
done

# 2. corpus cleaning (clean-corpus-n.perl)
# This removes sentence pairs that are too long, too short, or have a bad ratio.
$moses_scripts/training/clean-corpus-n.perl \
    "$data_dir/$prefix.tok" \
    $src $tgt \
    "$data_dir/$prefix.clean" \
    1 $max_len # Min length 1, Max length 100

# 3. truecasing (training) (train-truecaser.perl)
# The perl script learns from training data(train.10k.fi) what words should be capitalized.
for lang in $src $tgt; do
    model_file="$model_dir/truecase-model.$lang"
    corpus_file="$data_dir/$prefix.tok.$lang" # Train on tokenized, not cleaned

    $moses_scripts/recaser/train-truecaser.perl \
        --model $model_file \
        --corpus $corpus_file
done

# 4. truecasing (applying) (truecase.perl)
# This applies the models we just trained (using trian-trucase.perl) to our *cleaned* data.
for lang in $src $tgt; do
    input_file="$data_dir/$prefix.clean.$lang"
    output_file="$data_dir/$prefix.tc.$lang" # .tc = truecased
    model_file="$model_dir/truecase-model.$lang"
    
    $moses_scripts/recaser/truecase.perl \
        --model $model_file \
        < $input_file \
        > $output_file
done

# 5. split the 500k truecased data three ways (train, test, and valid)
# Split ratio: train (98%), test (1%), valid (1%)
for lang in $src $tgt; do
    input_file="$data_dir/temp.tc.$lang"
    cp "$data_dir/train.tc.$lang" $input_file
    
    # Get the total number of lines
    total_lines=$(wc -l < "$input_file")
    
    # Calculate split sizes
    train_size=$((total_lines * 98 / 100))
    test_size=$((total_lines * 1 / 100))
    # valid_size = remaining lines
    
    # Split the file
    head -n $train_size $input_file > "$data_dir/$prefix.tc.$lang"
    
    # Extract test set (from line train_size+1 to train_size+test_size)
    tail -n +$((train_size + 1)) $input_file | head -n $test_size > "$data_dir/test.tc.$lang"
    
    # Extract valid set (remaining lines)
    tail -n +$((train_size + test_size + 1)) $input_file > "$data_dir/valid.tc.$lang"
    
    echo "Split $lang into:"
    echo "  - train: $(wc -l < "$data_dir/train.tc.$lang") lines"
    echo "  - test: $(wc -l < "$data_dir/test.tc.$lang") lines"
    echo "  - valid: $(wc -l < "$data_dir/valid.tc.$lang") lines"
done

# 6. final clean-up (deleting .tok, .clean files)
rm $data_dir/temp.tc.$src
rm $data_dir/temp.tc.$tgt
rm $data_dir/$prefix.tok.$src
rm $data_dir/$prefix.tok.$tgt
rm $data_dir/$prefix.clean.$src
rm $data_dir/$prefix.clean.$tgt