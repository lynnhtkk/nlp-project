#!/bin/bash

# Script to preprocess Europarl data and run the full pipeline

# Set paths
raw_data_dir="data/raw"
preprocessed_dir="data/preprocessed"
scripts_dir="scripts"

# Source and target languages
src=fi
tgt=en

# Step 1: Extract first 500k lines from the raw TSV file
echo "Step 1: Extracting first 500k lines from europarl-v9.fi-en.tsv..."
head -n 500000 "$raw_data_dir/europarl-v9.fi-en.tsv" > "$raw_data_dir/europarl-v9.fi-en.500k.tsv"
echo "Saved to: $raw_data_dir/europarl-v9.fi-en.500k.tsv"

# Step 2: Extract columns and save as separate language files
echo "Step 2: Extracting columns from the 500k TSV file..."
cut -f1 "$raw_data_dir/europarl-v9.fi-en.500k.tsv" > "$preprocessed_dir/train.$src"
cut -f2 "$raw_data_dir/europarl-v9.fi-en.500k.tsv" > "$preprocessed_dir/train.$tgt"
echo "Saved to: $preprocessed_dir/train.$src and $preprocessed_dir/train.$tgt"

# Step 3: Run the preprocessing pipeline
echo "Step 3: Running preprocessing pipeline..."

echo "  - Running prepare.sh..."
bash "$scripts_dir/prepare.sh"

# echo "  - Running segmentation-A.sh..."
# bash "$scripts_dir/segmentation-A.sh"

# echo "  - Running run-morfessor.sh..."
# bash "$scripts_dir/run-morfessor.sh"

# echo "  - Running segmentation-B.sh..."
# bash "$scripts_dir/segmentation-B.sh"

# echo "All preprocessing steps completed!"