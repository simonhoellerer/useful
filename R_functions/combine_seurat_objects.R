### combine_seurat_objects ###
combine_seurat_objects <- function(object_list) {
  keys <- names(object_list)

  # Ensure all elements of input are named
  if (is.null(names(object_list)) || any(names(object_list) == "")) {
    stop("object_list must be a fully named list")
  }

  # Expand cell ids with the list keys to ensure uniqueness across objects
  for (key in keys) {
    seurat_obj <- object_list[[key]]

    seurat_obj <- RenameCells(object = seurat_obj, add.cell.id = key)
    object_list[[key]] <- seurat_obj
  }

  # Use Reduce to merge all Seurat objects in the list
  combined_object <- Reduce(function(x, y) merge(x, y, ), object_list)

  return(combined_object)
}
