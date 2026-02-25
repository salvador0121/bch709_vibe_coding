#!/usr/bin/env python3
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os


def main(data_file='gasch2000.txt', out_file='heatmap.png', top_n=10):
    if not os.path.exists(data_file):
        raise SystemExit(f"Data file not found: {data_file}")

    df = pd.read_csv(data_file, sep='\t', header=0, index_col=0, engine='python')

    # force numeric where possible
    for col in df.columns:
        df[col] = pd.to_numeric(df[col], errors='coerce')

    # drop all-empty columns/rows
    df = df.dropna(axis=1, how='all')
    df = df.dropna(axis=0, how='all')

    if df.shape[0] == 0 or df.shape[1] == 0:
        raise SystemExit('No numeric data found to plot.')

    # pick top genes by coefficient of variation (std / |mean|)
    eps = 1e-6
    mean_abs = df.mean(axis=1).abs().replace(0, eps)
    cv = df.std(axis=1, skipna=True) / (mean_abs + eps)
    top_idx = cv.sort_values(ascending=False).head(top_n).index
    df_plot = df.loc[top_idx]

    # row z-score for comparability
    df_plot = df_plot.apply(lambda x: (x - np.nanmean(x)) / (np.nanstd(x) if np.nanstd(x) != 0 else 1), axis=1)

    # Formatting per user's request
    figsize = (5, 5)
    dpi = 300
    cmap = 'PuGn'
    # ensure cmap exists in this matplotlib; fall back if necessary
    try:
        import matplotlib as mpl
        if cmap not in mpl.colormaps:
            fallback = 'PuBuGn'
            print(f"Requested colormap '{cmap}' not available; falling back to '{fallback}'")
            cmap = fallback
    except Exception:
        pass
    title = 'gene top 10'
    xlabel = 'gene'
    ylabel = 'conditions'
    fontname = 'Times New Roman'
    fontsize = 11
    description = 'gene expression is log scale'

    plt.figure(figsize=figsize, facecolor='white')
    sns.set(font_scale=1)
    plt.rcParams['font.family'] = 'serif'
    plt.rcParams['font.serif'] = [fontname]

    ax = sns.heatmap(df_plot, cmap=cmap, center=0, cbar=False, xticklabels=True, yticklabels=True)

    # add colorbar to top right
    cbar = plt.colorbar(ax.get_children()[0], ax=ax, orientation='vertical', fraction=0.046, pad=0.02)
    cbar.set_label(description, fontsize=fontsize, fontname=fontname)
    # position colorbar to top-right by adjusting its axes
    cbar.ax.yaxis.set_ticks_position('right')

    # Titles and axis labels
    ax.set_title(title, fontsize=fontsize, fontname=fontname)
    ax.set_xlabel(xlabel, fontsize=fontsize, fontname=fontname)
    ax.set_ylabel(ylabel, fontsize=fontsize, fontname=fontname)

    # ticks and rotation
    plt.xticks(rotation=45, ha='right', fontsize=fontsize, fontname=fontname)
    plt.yticks(rotation=0, fontsize=fontsize, fontname=fontname)

    # heatmap border (axes spines)
    for spine in ax.spines.values():
        spine.set_edgecolor('black')
        spine.set_linewidth(1.0)

    ax.set_facecolor('white')

    plt.tight_layout()
    plt.savefig(out_file, dpi=dpi, facecolor='white', edgecolor='black')
    print('Saved', out_file)


if __name__ == '__main__':
    main()
