#!/bin/bash
# Quick Start Script for BCH709 Heatmap Analysis

echo "================================"
echo "BCH709 Gene Expression Heatmap"
echo "================================"
echo ""

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "ERROR: conda was not found. Please install Miniconda or Anaconda first."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "Step 1: Creating conda environment..."
echo "Command: conda env create -f environment.yml"
conda env create -f environment.yml -y

echo ""
echo "Step 2: Activating environment..."
echo "Command: conda activate bch709_heatmap"
eval "$(conda shell.bash hook)"
conda activate bch709_heatmap

echo ""
echo "Step 3: Running R analysis..."
echo "Command: Rscript heatmap_analysis.R"
Rscript heatmap_analysis.R

echo ""
echo "================================"
echo "Analysis complete!"
echo "================================"
echo ""
echo "Output file: heatmap_top10_genes.png"
echo "See INSTRUCTIONS.md for detailed documentation"
