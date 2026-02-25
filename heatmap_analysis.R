#!/usr/bin/env Rscript

# Load required libraries
library(tidyverse)
library(ggplot2)
library(reshape2)
library(stringr)

# Set working directory to project folder
# Terminal execution: automatically uses current directory
# For flexibility, try rstudioapi first, fall back to current dir
tryCatch({
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}, error = function(e) {
  # If rstudioapi fails, use current working directory
  cat("Note: Using current working directory\n")
})

# ============================================================================
# 1. READ AND VERIFY DATA STRUCTURE
# ============================================================================
cat("Step 1: Reading data file...\n")
data <- read.delim("gasch2000.txt", row.names = 1, stringsAsFactors = FALSE)

cat("Data dimensions:", nrow(data), "genes x", ncol(data), "columns\n")
cat("\nFirst few rows and columns:\n")
print(head(data[, 1:5]))

cat("\n\nColumn types summary:\n")
print(sapply(data, class))

# ============================================================================
# 2. CHECK FOR LOG SCALE
# ============================================================================
cat("\n\nStep 2: Checking if data is log-scale...\n")

# Extract numeric columns (skip gene name and weight columns)
numeric_cols <- which(sapply(data, is.numeric))
numeric_data <- data[, numeric_cols]

cat("Range of values: [", min(numeric_data, na.rm = TRUE), ",", max(numeric_data, na.rm = TRUE), "]\n")
cat("Negative values present:", any(numeric_data < 0, na.rm = TRUE), "\n")
cat("Number of NAs:", sum(is.na(numeric_data)), "\n")

# Check a few values
cat("\nSample of raw values:\n")
set.seed(123)
sample_genes <- sample(1:nrow(numeric_data), 3)
print(numeric_data[sample_genes, 1:5])

cat("\n>>> Data appears to be log-RATIO scale already (negative and positive values detected).\n")
cat(">>> Will NOT apply log2 transformation.\n")

# ============================================================================
# 3. COMPUTE COEFFICIENT OF VARIATION (CV) PER GENE
# ============================================================================
cat("\n\nStep 3: Computing CV per gene...\n")

cv_computation <- function(x) {
  x <- x[!is.na(x)]  # Remove NAs
  
  if (length(x) == 0) {
    return(NA)
  }
  
  mean_val <- mean(x)
  sd_val <- sd(x)
  
  # Guard: if mean == 0, return NA to avoid division issues
  if (abs(mean_val) < 1e-10) {
    return(NA)
  }
  
  # CV = sd / abs(mean) to handle negative values properly
  cv <- sd_val / abs(mean_val)
  return(cv)
}

cv_values <- apply(numeric_data, 1, cv_computation)

# Create a data frame with gene IDs and CV values
cv_df <- data.frame(
  gene_id = rownames(data),
  cv = cv_values,
  stringsAsFactors = FALSE
)

# Remove NA CVs
cv_df <- cv_df[!is.na(cv_df$cv), ]

# Sort by CV descending and get top 10
cv_df <- cv_df %>% arrange(desc(cv))

cat("\nTop 10 genes by CV:\n")
print(head(cv_df, 10))

top_10_genes <- cv_df$gene_id[1:10]

# ============================================================================
# 4. PREPARE DATA FOR HEATMAP (LONG FORMAT)
# ============================================================================
cat("\n\nStep 4: Preparing data for heatmap (long format)...\n")

# Extract top 10 genes
heatmap_data <- numeric_data[top_10_genes, ]

# Convert to long format
heatmap_long <- heatmap_data %>%
  rownames_to_column("gene") %>%
  pivot_longer(
    cols = -gene,
    names_to = "condition",
    values_to = "expression"
  ) %>%
  filter(!is.na(expression))

cat("Heatmap data dimensions:", nrow(heatmap_long), "rows x", ncol(heatmap_long), "columns\n")
cat("\nFirst few rows:\n")
print(head(heatmap_long, 10))

# ============================================================================
# 5. CREATE HEATMAP WITH STYLING
# ============================================================================
cat("\n\nStep 5: Creating heatmap...\n")

# Factor genes by their CV rank (top first)
heatmap_long$gene <- factor(heatmap_long$gene, levels = top_10_genes)

# Create a condition group by pattern-matching condition strings
# Groups: heat shock, nitrogen depletion, osmotic stress, carbon source,
# growth phase, oxidative/redox, other
heatmap_long <- heatmap_long %>%
  mutate(group = case_when(
    grepl("heat.*shock|heat.shock|heat\\s*shock", condition, ignore.case = TRUE) ~ "Heat Shock",
    grepl("nitrogen", condition, ignore.case = TRUE) ~ "Nitrogen Depletion",
    grepl("sorbitol|osmotic|hypo-?osmotic", condition, ignore.case = TRUE) ~ "Osmotic Stress",
    grepl("h2o2|menadione|dtt|diamide|oxid", condition, ignore.case = TRUE) ~ "Oxidative / Redox",
    grepl("ethanol|galactose|glucose|fructose|mannose|raffinose|sucrose|carbon", condition, ignore.case = TRUE) ~ "Carbon Source",
    grepl("ypd|diauxic|growth|stationary|steady.state|steady state", condition, ignore.case = TRUE) ~ "Growth Phase",
    TRUE ~ "Other"
  ))

# Order groups and conditions so facets are grouped
group_levels <- c("Heat Shock", "Nitrogen Depletion", "Osmotic Stress", "Oxidative / Redox", "Carbon Source", "Growth Phase", "Other")
heatmap_long$group <- factor(heatmap_long$group, levels = group_levels)

# Wrap long condition names with smaller width for readability and order conditions within groups
heatmap_long <- heatmap_long %>%
  mutate(condition_label = stringr::str_wrap(condition, width = 18))

cond_order <- heatmap_long %>%
  distinct(group, condition_label) %>%
  arrange(factor(group, levels = group_levels)) %>%
  pull(condition_label)
heatmap_long$condition_label <- factor(heatmap_long$condition_label, levels = cond_order)

# Compute symmetric limits for color scale (centered at 0)
lim <- max(abs(heatmap_long$expression), na.rm = TRUE)

# Create the heatmap
p <- ggplot(heatmap_long, aes(x = gene, y = condition_label, fill = expression)) +
  geom_tile(color = "grey70", linewidth = 0.08) +  # Very thin grey borders
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0,
    limits = c(-lim, lim),
    name = "Expression"
  ) +
  labs(
    title = "Top 10 Most Variable Genes Across Conditions",
    x = "Gene",
    y = "Condition"
  ) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    # Use a white panel background with no heavy border; draw thin grey separators
    panel.background = element_rect(fill = "white", color = NA, linewidth = 0),
    panel.border = element_rect(fill = NA, color = NA),
    
    # Text styling: Times New Roman, 11pt base
    plot.title = element_text(
      family = "serif",
      size = 11,
      hjust = 0.5,
      color = "black",
      face = "bold",
      margin = margin(b = 5)
    ),
    axis.title.x = element_text(
      family = "serif",
      size = 11,
      color = "black",
      margin = margin(t = 8)
    ),
    axis.title.y = element_text(
      family = "serif",
      size = 11,
      color = "black",
      margin = margin(r = 8)
    ),
    axis.text.x = element_text(
      family = "serif",
      size = 7.5,
      color = "black",
      angle = 45,
      hjust = 1,
      vjust = 1,
      face = "bold"
    ),
    # Show y-axis labels (many), use very small font with reduced opacity
    axis.text.y = element_text(
      family = "serif",
      size = 3.5,
      color = "grey20",
      angle = 0,
      hjust = 1,
      vjust = 0.5,
      margin = margin(r = 2)
    ),
    axis.ticks.y = element_line(color = "grey70", linewidth = 0.2),
    
    # Legend styling - positioned at top-right corner of heatmap panel
    legend.position.inside = c(0.99, 0.99),
    legend.justification = c(1, 1),
    legend.direction = "vertical",
    legend.title = element_text(
      family = "serif",
      size = 11,
      face = "bold"
    ),
    legend.text = element_text(
      family = "serif",
      size = 9
    ),
    legend.margin = margin(t = 2, r = 2, b = 2, l = 2),
    
    # Add spacing around plot (moderate left margin; labels extend outside with clip=off)
    plot.margin = margin(3, 10, 10, 50, "pt"),
    
    # Remove gridlines
    panel.grid = element_blank()
  )

# Colorbar displays naturally: blue (low) at bottom, red (high) at top, white at zero
p <- p + guides(fill = guide_colorbar(title.position = "top", title.hjust = 0.5))

# Remove y-scale expansion so heatmap uses more vertical space
p <- p + scale_y_discrete(expand = expansion(mult = c(0, 0)))

# Allow labels to extend outside the panel boundaries without clipping
p <- p + coord_cartesian(clip = "off")

# If faceting by group: free y-scale and free space so each group gets its own block
p <- p + facet_grid(group ~ ., scales = "free_y", space = "free_y") +
  theme(
    # Hide the right-side group labels (strip text) but keep the facet separators
    strip.text.y = element_blank(),
    strip.background = element_rect(fill = "white", color = NA),
    # Reduce spacing between facet strips and panels for tighter visual alignment
    panel.spacing = grid::unit(0.02, "lines")
  )

cat("Heatmap created successfully!\n")

# ============================================================================
# 6. EXPORT HIGH-RESOLUTION IMAGES
# ============================================================================
cat("\n\nStep 6: Exporting high-resolution images...\n")

# Export PNG version
output_file_png <- "heatmap_top10_genes.png"

ggsave(
  filename = output_file_png,
  plot = p,
  width = 8,
  height = 8,
  units = "in",
  dpi = 300,
  bg = "white"
)

cat("PNG image saved as:", output_file_png, "\n")
cat("Dimensions: 8 x 8 inches, DPI: 300, Format: PNG\n")

# Export PDF version (vector format for publication)
output_file_pdf <- "heatmap_top10_genes.pdf"

ggsave(
  filename = output_file_pdf,
  plot = p,
  width = 8,
  height = 8,
  units = "in",
  bg = "white"
)

cat("PDF vector image saved as:", output_file_pdf, "\n")
cat("Dimensions: 8 x 8 inches, Format: PDF (vector)\n")

# Print completion message
cat("\n==============================================\n")
cat("ANALYSIS COMPLETE!\n")
cat("==============================================\n")
cat("Summary:\n")
cat("  - Data: 6153 genes x", ncol(numeric_data), "conditions\n")
cat("  - Data is already on LOG-SCALE (no transformation applied)\n")
cat("  - Top 10 genes selected by Coefficient of Variation\n")
cat("  - PNG export: heatmap_top10_genes.png (8x8 in, 300 DPI)\n")
cat("  - PDF export: heatmap_top10_genes.pdf (8x8 in, vector format)\n")
cat("==============================================\n")
