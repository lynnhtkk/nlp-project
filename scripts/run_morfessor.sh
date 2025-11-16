#!/bin/bash

# !! Should be run from the root directory (BPC_NLP_PROJECT) !!
# Assumes morfessor is already installed (If not, install via `pip install morfessor`)

# Source and Target Languages
src=fi
tgt=en

# Path Variables
data_dir="data/preprocessed"
output_dir="pipeline_B_morfessor"
models_dir="$output_dir/models"

# Settings
prefix="train"

# 1. Train Morfessor Models
for lang in $src $tgt; do
    morfessor-train "$data_dir/$prefix.tc.$lang" \
    -s "$models_dir/morfessor-model.$lang"
done

# 2. Apply Morfessor Models (Segmentation)
# We apply the trained models to the *same* data to create the segmented .morf files.
for lang in $src $tgt; do
    morfessor-segment -l "$models_dir/morfessor-model.$lang"\
        "$data_dir/$prefix.tc.$lang"\
        -o "$output_dir/data/train.morf.$lang" \
        --output-format '{analysis} ' \
        --output-format-separator "## " \
        --output-newlines
done