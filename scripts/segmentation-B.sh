#!/bin/bash

# !! Should be run from the root directory (BPC_NLP_PROJECT) !!
src=fi
tgt=en

# Path Variables
data_dir="pipeline_B_morfessor/data"
output_dir="pipeline_B_morfessor"
bpe_scripts="tools/subword-nmt/subword_nmt"

# BPE Settings (parameter values)
prefix="train"
bpe_ops=10000 # number of bpe merge operations {num_operations} 


# Output BPE model (the merge rules)
bpe_code_file="$output_dir/models/bpe-codes.$bpe_ops"

# 1. Learn the BPE Segmentation on the concatenation of training text, and get vocabulary for each language
python3 $bpe_scripts/learn_joint_bpe_and_vocab.py \
    --input "$data_dir/$prefix.morf.$src" "$data_dir/$prefix.morf.$tgt" \
    -s $bpe_ops \
    -o $bpe_code_file \
    --write-vocabulary "$output_dir/models/vocab.$src" "$output_dir/models/vocab.$tgt"

# 2. Apply BPE with Vocabulary Filtering
for split in train test valid; do
    for lang in $src $tgt; do
        python3 $bpe_scripts/apply_bpe.py \
            -c $bpe_code_file \
            --vocabulary "$output_dir/models/vocab.$lang" \
            --vocabulary-threshold 50 \
            < "$data_dir/$split.morf.$lang" \
            > "$output_dir/data/$split.bpe.$lang"
    done
done