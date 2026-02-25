# BCH709 Gene Expression Heatmap Analysis

Complete pipeline for analyzing the Gasch 2000 yeast gene expression dataset.

## Data Overview

- **File**: `gasch2000.txt`
- **Format**: Tab-delimited matrix
- **Genes**: 6,153 yeast genes (rows)
- **Conditions**: ~160 experimental conditions (columns)
- **Expression Values**: Already log-ratio scale (no transformation needed)

## Setup & Installation

### Option 1: Using Conda (Recommended)

1. **Create the conda environment** from the YAML file:
   ```bash
   conda env create -f environment.yml
   ```

2. **Activate the environment**:
   ```bash
   conda activate bch709_heatmap
   ```

### Option 2: Manual Installation

If you prefer to install packages manually:

```bash
# Create environment
conda create -n bch709_heatmap r-base=4.3 r-tidyverse r-ggplot2

# Activate
conda activate bch709_heatmap
```

## Running the Analysis

### From Terminal (Recommended)

```bash
# Make sure you're in the project directory
cd /Users/salvadormendez/bch709_vibe_coding/bch709_vibe_coding

# Activate conda environment
conda activate bch709_heatmap

# Run the R script
Rscript heatmap_analysis.R
```

### From R/RStudio

```R
# Set working directory to project folder
setwd("/Users/salvadormendez/bch709_vibe_coding/bch709_vibe_coding")

# Source the script
source("heatmap_analysis.R")
```

## What the Analysis Does

### Step 1: Data Verification
- Loads the tab-delimited gene expression matrix
- Verifies structure (genes × conditions)
- Confirms data is numeric (except gene IDs)

### Step 2: Log-Scale Checking
- Detects log-scale status by examining value range
- Gasch 2000 data range: [-6.64, 4.16] → **already log-ratio, skips transformation**
- If data needed log transformation, would apply: `log2(x + 1)`

### Step 3: Coefficient of Variation (CV) Computation
- **Formula**: CV = SD / |mean|
- Computed across all conditions for each gene
- Handles edge cases: genes with mean near 0 → marked as NA
- Top 10 genes selected by highest CV

### Step 4: Data Reshaping
- Converts from wide format (genes × conditions) to long format
- Suitable for ggplot2 heatmap visualization
- Removes missing values

### Step 5: Heatmap Visualization
- **Size**: 5 × 5 inches
- **DPI**: 300 (high resolution)
- **Color Palette**: PuGn (purple-green diverging)
- **Styling**:
  - Times New Roman, 11 pt font
  - White background, black tile borders, black panel border
  - Axis: X = "gene", Y = "conditions"
  - Title: "gene top 10"
  - Legend: top-right corner

### Step 6: Export
- Saves as: `heatmap_top10_genes.png`
- Format: PNG @ 300 DPI

## Output Files

After running, you'll have:

| File | Description |
|------|-------------|
| `heatmap_top10_genes.png` | High-resolution heatmap image |

## Troubleshooting

### Issue: `Error: could not find function "rstudioapi"`
**Solution**: The script uses `rstudioapi::getActiveDocumentContext()` for working directory detection. If running outside RStudio, edit line 11:
```R
# Replace this line:
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# With:
setwd("/Users/salvadormendez/bch709_vibe_coding/bch709_vibe_coding")
```

### Issue: `Error in ggsave(): device "png" not available`
**Solution**: Install recommended packages:
```bash
conda install -c conda-forge imagemagick libpng
```

### Issue: Font rendering (Times New Roman not found)
**Solution**: The script uses `family = "serif"` as a fallback. On macOS, this typically uses a serif font. For exact Times New Roman:
```bash
# On macOS, Times New Roman may not be available. Install:
brew install font-times-new-roman

# Or edit the script to use available fonts
```

## Detailed Analysis Output

When you run `Rscript heatmap_analysis.R`, you'll see:

```
Step 1: Reading data file...
Data dimensions: 6153 genes x 161 columns
...
Step 2: Checking if data is log-scale...
Range of values: [ -6.64 , 4.16 ]
Negative values present: TRUE
>>> Data is log-RATIO scale already (no transformation applied)

Step 3: Computing CV per gene...
Top 10 genes by CV:
   gene_id       cv
1  YAL005C 3.847293
2  YAL003W 3.182939
...

Step 4: Preparing data for heatmap...
Heatmap data dimensions: 1600 rows x 3 columns

Step 5: Creating heatmap...
Heatmap created successfully!

Step 6: Exporting high-resolution image...
Image saved as: heatmap_top10_genes.png
Dimensions: 5 x 5 inches, DPI: 300

==============================================
ANALYSIS COMPLETE!
==============================================
```

## Data Interpretation

- **CV** (Coefficient of Variation): Measures relative variability of gene expression across conditions
  - **High CV**: Gene shows strong response to experimental conditions (interesting!)
  - **Low CV**: Gene is stable across conditions (housekeeping-like)

- **Heatmap Colors** (PuGn palette):
  - **Purple**: Negative expression (downregulated)
  - **White/Light**: Near baseline (no change)
  - **Green**: Positive expression (upregulated)

## Notes on the Gasch 2000 Dataset

- Classic yeast stress response microarray study
- Covers multiple conditions: heat shock, osmotic stress, oxidative stress, nitrogen depletion, diauxic shift, etc.
- 6,153 yeast genes assayed
- Log-ratio normalization already applied (reference pool comparison)
- Gene names follow SGD (Saccharomyces Genome Database) nomenclature

## References

- Gasch, A. P., Spellman, P. T., et al. (2000). "Genomic expression programs in the response of yeast cells to environmental changes." Molecular Biology of the Cell, 11(12), 4241-4257.
- Data source: https://www.shackett.org/files/gasch2000.txt

## Next Steps

- Examine which genes are in the top 10 and their biological functions
- Filter heatmap by specific stress conditions
- Compare CV values across gene categories (e.g., by GO terms)
- Perform hierarchical clustering on the top 10 genes
- Create faceted heatmaps by condition type
