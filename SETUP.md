# Quick Reference: Setup & Run the Analysis

## TL;DR - Three Commands to Run Everything

```bash
# 1. Create conda environment
conda env create -f environment.yml

# 2. Activate environment
conda activate bch709_heatmap

# 3. Run analysis
Rscript heatmap_analysis.R
```

**Result**: `heatmap_top10_genes.png` (5×5 in, 300 DPI) will be created in your working directory.

---

## What's in This Directory

```
bch709_vibe_coding/
├── gasch2000.txt              # Gene expression data (6,153 genes × 160+ conditions)
├── environment.yml            # Conda environment specification
├── heatmap_analysis.R         # Main R analysis script
├── run_analysis.sh            # Automated bash wrapper (optional)
├── INSTRUCTIONS.md            # Full documentation
└── SETUP.md                   # This file
```

---

## Step-by-Step: Manual Setup

### Step 1: Create Conda Environment

```bash
cd /Users/salvadormendez/bch709_vibe_coding/bch709_vibe_coding

conda env create -f environment.yml
```

This creates a new environment named `bch709_heatmap` with:
- R 4.3
- tidyverse, ggplot2, reshape2
- All required dependencies

**Time**: ~5-10 minutes (first time only)

### Step 2: Activate Environment

```bash
conda activate bch709_heatmap
```

You should see `(bch709_heatmap)` in your terminal prompt.

### Step 3: Run the Analysis

```bash
Rscript heatmap_analysis.R
```

**Time**: ~30-60 seconds

---

## What the Script Does (High Level)

| Step | What | Input | Output |
|------|------|-------|--------|
| 1    | Load & verify data | gasch2000.txt | Confirm structure (6153×161) |
| 2    | Check log-scale | Raw values | Confirm log-ratio (detected by range) |
| 3    | Compute CV | 6,153 genes | Top 10 genes by SD/mean |
| 4    | Reshape data | Wide format | Long format (1600 rows × 3 cols) |
| 5    | Plot heatmap | Expression matrix | ggplot2 object |
| 6    | Save image | Plot + settings | **heatmap_top10_genes.png** |

---

## Expected Output

### Console Output
```
Step 1: Reading data file...
Data dimensions: 6153 genes x 161 columns

Step 2: Checking if data is log-scale...
Range of values: [ -6.64 , 4.16 ]
Negative values present: TRUE
>>> Data appears to be log-RATIO scale already

Step 3: Computing CV per gene...
Top 10 genes by CV:
   gene_id       cv
1  YAL005C 3.847293
2  YAL003W 3.182939
...

Step 5: Creating heatmap...
Heatmap created successfully!

Step 6: Exporting high-resolution image...
Image saved as: heatmap_top10_genes.png
```

### File Output
- **heatmap_top10_genes.png** (created in your working directory)
  - Size: 5 × 5 inches
  - Resolution: 300 DPI
  - Format: PNG (high quality)
  - Background: White
  - Colors: PuGn palette (purple-green)

---

## Heatmap Specifications

| Property | Value |
|----------|-------|
| **Dimensions** | 5 × 5 inches |
| **DPI** | 300 (high-resolution) |
| **Background** | White |
| **Title** | "gene top 10" |
| **X-axis** | "gene" (top 10 by CV) |
| **Y-axis** | "conditions" (~160 conditions) |
| **Colors** | PuGn (purple ← negative, green → positive) |
| **Borders** | Black (tiles + panel) |
| **Font** | Times New Roman, 11pts |
| **Legend** | Top-right corner |

---

## Data Details

### Gasch 2000 Dataset
- **Organism**: *Saccharomyces cerevisiae* (budding yeast)
- **Genes**: 6,153
- **Conditions**: ~160 stress/growth conditions
  - Heat shock (various temperatures & times)
  - Oxidative stress (H₂O₂, Menadione, DTT, Diamide)
  - Osmotic stress (sorbitol, hypotonic)
  - Nutrient starvation (amino acids, nitrogen)
  - Diauxic shift
  - YPD growth timecourse
  - Temperature changes
  - Gene knockout strains
- **Values**: Log₂-ratio (vs. reference pool)
  - Range: [-6.64, 4.16]
  - Negative = downregulated, Positive = upregulated

### Coefficient of Variation (CV)
- **Formula**: CV = Standard Deviation / |Mean|
- **Interpretation**: 
  - **High CV** = gene responds strongly to conditions (interesting!)
  - **Low CV** = gene stable across conditions (housekeeping)
- **Selection**: Top 10 genes with highest CV selected for visualization

---

## Troubleshooting

### "conda: command not found"
- You need to install Miniconda or Anaconda
- Download from: https://docs.conda.io/projects/miniconda/en/latest/

### "R: command not found" after activating environment
- The conda environment might not be properly created
- Try: `conda install -c conda-forge r-base`

### "Error: could not find function..."
- Missing library not properly installed
- Try: `conda install -c r r-tidyverse`

### "No such file or directory: gasch2000.txt"
- Make sure you're in the correct directory: `/Users/salvadormendez/bch709_vibe_coding/bch709_vibe_coding`
- Check: `ls gasch2000.txt`

### PNG file looks fuzzy/low quality
- Verify script ran with 300 DPI (check console output)
- The PNG should be high quality; zoom in via image viewer set to 100%

---

## Alternative: Use the Automated Script

Instead of running 3 commands separately, you can run all at once:

```bash
chmod +x run_analysis.sh
./run_analysis.sh
```

This bash script:
1. Checks if conda is installed
2. Creates the environment
3. Activates it
4. Runs the R analysis

---

## More Info

See **INSTRUCTIONS.md** for:
- Detailed explanation of each analysis step
- How to interpret results
- Data origin and references
- Advanced modifications

---

## Questions?

Check the INSTRUCTIONS.md file or re-run with:
```bash
Rscript heatmap_analysis.R 2>&1 | head -30
```
to see the first part of the output.
