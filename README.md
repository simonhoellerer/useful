# useful

This repository contains a list of bash settings and R functions that I find useful.

## Content

### R functions

- ./R_functions/HEAD.R
  Retrieve the first rows and columns of a matrix or data frame (top‑left block).

- ./R_functions/TAIL.R
  Retrieve the last rows and columns of a matrix or data frame (bottom‑right block).

- ./R_functions/combine_seurat_objects.R  
  Combine multiple named Seurat objects into a single object, expanding cell IDs to preserve uniqueness.

- ./R_functions/get_colors.R
  Generate a named vector of colors for clusters or samples from a specified column in a data frame, using a chosen color palette.

- ./R_functions/mem_size_ls.R
  List objects in the environment along with their memory usage for quick inspection.

- ./R_functions/norm_int_umap_clust.R
  Normalize and integrate RNA‑seq data and generate a UMAP with clustering (Seurat workflow helper).

- ./R_functions/scale_dotplot.R
  Apply consistent color scaling to Seurat dot plots.

- ./R_functions/standardize_celltypes.R
  Standardize and harmonize cell type labels in Seurat metadata.

- ./R_functions/theme_dotplot.R
  Custom ggplot2 theme optimized for dot plots.

- ./R_functions/uniques.R
  Count unique values in a vector or column, returning a compact summary.

### Bash

- ./.bashrc
  Custom bash settings and aliases for interactive shell usage.
