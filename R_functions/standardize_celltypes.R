### standardize_celltypes.R ###

# This function standardizes cell type labels in a Seurat object based on a
# reference table. It reads a CSV file containing old and new cell type names,
# matches the cell type labels in the Seurat object's metadata to the reference,
# and updates the labels accordingly.

standardize_celltypes <- function(seurat_obj, column = "cell_type") {
  # Read reference
  ref_table <- read.csv(
    "/path/to/standardized_celltypes.csv",
    header = TRUE, colClasses = "character", comment.char = ""
  )

  # Extract meta data and the column to standardize
  meta <- seurat_obj@meta.data
  cell_vec <- meta[[column]]

  # Handle NAs safely for the summary statistics
  unique_celltypes <- sort(unique(cell_vec))
  unique_celltypes_nna <- unique_celltypes[!is.na(unique_celltypes)]

  old_names <- ref_table$old_name
  new_names <- ref_table$new_name

  # Membership of unique types in reference
  in_old <- unique_celltypes_nna %in% old_names
  in_new <- unique_celltypes_nna %in% new_names

  # Summary counts on unique cell types
  total_ct     <- length(unique_celltypes_nna)
  found_ct     <- sum(in_old | in_new)
  unchanged_ct <- sum(!in_old & in_new)   # only in new_name
  renamed_ct   <- sum(in_old & !in_new)   # only in old_name
  ambiguous_ct <- sum(in_old & in_new)    # in both old_name and new_name

  # Name sets (for potential inspection)
  missing_types   <- sort(unique_celltypes_nna[!(in_old | in_new)])
  unchanged_types <- sort(unique_celltypes_nna[!in_old & in_new])
  renamed_types   <- sort(unique_celltypes_nna[in_old & !in_new])
  ambiguous_types <- sort(unique_celltypes_nna[in_old & in_new])

  # Print requested summary
  cat("Cell types in data:     ", total_ct, "\n")
  cat("Cell types in reference:", found_ct, "\n")
  cat("Cell types unchanged:   ", unchanged_ct, "\n")
  cat("Cell types renamed:     ", renamed_ct, "\n")

  if (ambiguous_ct > 0) {
    cat("Cell types matching both old_name and new_name (ambiguous):", ambiguous_ct, "\n")
    cat("Ambiguous types (left unchanged because they already match new_name):\n",
        paste(ambiguous_types, collapse = "\n"), "\n")
  }

  # ---- Renaming logic at the cell level ----
  # Rule:
  # 1) If a label is in new_names -> leave unchanged
  # 2) Else if it is in old_names -> map to corresponding new_name
  # 3) Else                       -> leave as is (but report as missing)

  new_vec <- cell_vec

  # Indices of cells that are candidates for renaming (not already standardized)
  idx_to_rename <- which(!(cell_vec %in% new_names) & (cell_vec %in% old_names))

  # Prepare mapping old_name -> new_name (for both renaming and printing)
  map_old_to_new <- setNames(new_names, old_names)

  if (length(idx_to_rename) > 0) {
    # Apply mapping
    new_vec[idx_to_rename] <- unname(map_old_to_new[cell_vec[idx_to_rename]])

    # Construct unique mapping actually used in this object
    old_vals_used <- cell_vec[idx_to_rename]
    new_vals_used <- new_vec[idx_to_rename]

    mapping_df <- tibble::tibble(
      old = old_vals_used,
      new = new_vals_used
    ) %>%
      dplyr::distinct(old, new) %>%
      dplyr::arrange(old, new)

    cat("Following cell types were renamed:\n")
    cat(paste0(mapping_df$old, " --> ", mapping_df$new), sep = "\n")
    cat("\n")
  }

  # Cell types that don't match either old_name or new_name (per-cell view)
  unmatched_cells <- cell_vec[!(cell_vec %in% old_names | cell_vec %in% new_names)]
  unmatched_cells <- unique(unmatched_cells[!is.na(unmatched_cells)])

  if (length(unmatched_cells) == 0) {
    cat("All cell types found in reference table.\n")
  } else {
    cat("These cell types were not found in the reference table:\n",
        paste(unmatched_cells, collapse = "\n"), "\n")
  }

  # Write back
  meta[[column]] <- new_vec
  seurat_obj@meta.data <- meta

  return(seurat_obj)
}
