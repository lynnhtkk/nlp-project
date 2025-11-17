#!/bin/bash

# Script to check the number of lines in segmented data files

echo "====== Pipeline A (BPE) Data Statistics ======"
echo ""
for file in pipeline_A_baseline/data/*.bpe.*; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        echo "$file: $lines lines"
    fi
done

echo ""
echo "====== Pipeline B (Morfessor) Data Statistics ======"
echo ""
for file in pipeline_B_morfessor/data/*.morf.*; do
    if [ -f "$file" ]; then
        lines=$(wc -l < "$file")
        echo "$file: $lines lines"
    fi
done

echo ""
echo "Data statistics check completed!"
