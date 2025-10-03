#!/bin/bash
# Example script to run ProteinMPNN design
# Usage: ./run_example.sh <input.pdb>

set -e

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input.pdb>"
    echo "Example: $0 /path/to/protein.pdb"
    exit 1
fi

INPUT_PDB=$1
INPUT_DIR=$(dirname "$INPUT_PDB")
OUTPUT_DIR="./output"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Running ProteinMPNN on: $INPUT_PDB"
echo "Output will be saved to: $OUTPUT_DIR"

docker run --gpus all \
  -v "$INPUT_DIR":/app/input \
  -v "$OUTPUT_DIR":/app/output \
  proteinmpnn-cuda12.1 \
  python /app/ProteinMPNN/protein_mpnn_run.py \
    --pdb_path /app/input/$(basename "$INPUT_PDB") \
    --out_folder /app/output \
    --num_seq_per_target 10 \
    --sampling_temp 0.1 \
    --seed 37 \
    --batch_size 1

echo "Done! Check $OUTPUT_DIR for results."
