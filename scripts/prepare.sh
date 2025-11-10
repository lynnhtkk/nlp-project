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
prefix="train.10k"

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

# 5. final clean-up (deleting .tok, .clean files)
rm $data_dir/$prefix.tok.$src
rm $data_dir/$prefix.tok.$tgt
rm $data_dir/$prefix.clean.$src
rm $data_dir/$prefix.clean.$tgt