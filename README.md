Generate Heatmap from the Gasch 2000 Dataset

This repository contains code used to generate a heatmap of the top 10 most variable genes across experimental conditions using the Gasch et al. (2000) dataset.

Requirements

A Conda environment can be created using:

conda env create -f environment.yml
conda activate bch709_heatmap

Usage

Run the analysis using R:

Rscript heatmap_analysis.R

Output

The analysis generates:

- heatmap_top10_genes.png
- heatmap_top10_genes.pdf

in the repository root directory.