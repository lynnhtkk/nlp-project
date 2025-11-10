#!/bin/bash

# !! Should be run from the root directory (BPC_NLP_PROJECT) !!
src=fi
tgt=en

# Path Variables
data_dir="data/preprocessed"
output_dir="pipeline_A_baseline"
bpe_scripts="tools/subword-nmt/subword_nmt"

# BPE Settings (parameter values)
prefix="train.10k"
bpe_ops=10000 # number of bpe merge operations {num_operations} 

# File Paths
src_train_file="$data_dir/$prefix.tc.$src"
tgt_train_file="$data_dir/$prefix.tc.$tgt"

# Output BPE model (the merge rules)
bpe_code_file="$output_dir/bpe-codes.$bpe_ops"

# 1. Learn the BPE Segmentation on the concatenation of training text, and get vocabulary for each language
python3 $bpe_scripts/learn_joint_bpe_and_vocab.py \
    --input "$data_dir/$prefix.tc.$src" "$data_dir/$prefix.tc.$tgt" \
    -s $bpe_ops \
    -o $bpe_code_file \
    --write-vocabulary "$output_dir/vocab.$src" "$output_dir/vocab.$tgt"

# 2. Apply BPE with Vocabulary Filtering
for lang in $src $tgt; do
    python3 $bpe_scripts/apply_bpe.py \
        -c $bpe_code_file \
        --vocabulary "$output_dir/vocab.$lang" \
        --vocabulary-threshold 50 \
        < "$data_dir/$prefix.tc.$lang" \
        > "$output_dir/$prefix.bpe.$lang"
done