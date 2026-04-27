### norm_int_umap_clust.R ###

# This function performs a standard workflow for single-cell RNA-seq data
# analysis using Seurat. It includes normalization with SCTransform,
# dimensionality reduction with PCA, integration using Harmony, UMAP
# visualization, and clustering. The function is designed to be flexible with
# various parameters for each step of the analysis. Each step is performed with
# a specified random seed for reproducibility, and followed by garbage collection
# to manage memory usage.

norm_int_umap_clust <- function(
  obj,
  n_features      = 3000,
  vars.to.regress = NULL,
  add.markers     = NULL,
  npcs            = 50,
  method          = "HarmonyIntegration",
  umap.method     = "uwot",
  metric          = "cosine",
  n.neighbors     = 30,
  spread          = 1,
  min.dist        = 0.3,
  vec_res         = 0.8,
  algorithm       = 4,
  seed            = 12345L,
  run_pca_umap    = TRUE,
  verbose         = TRUE
) {
  # Construct the multi-line message
  algo_label <- dplyr::case_when(
    algorithm == 1 ~ "Louvain",
    algorithm == 4 ~ "Leiden",
    TRUE ~ as.character(algorithm)
  )

  vars_str <- if (is.null(vars.to.regress)) {
    "NULL"
  } else {
    paste(vars.to.regress, collapse = ", ")
  }

  vars_markers_str <- if (is.null(add.markers)) {
    "NULL"
  } else {
    paste(head(add.markers, 10), collapse = ", ")
  }

  msg <- glue::glue(
    "Data is normalized using Seurat::SCTransform() with n_features = {n_features}\n",
    if (!is.null(add.markers)) "Adding additional markers to scale.data with add.markers = {vars_markers_str} (top 10 shown)\n" else "",
    "Running PCA with Seurat::RunPCA() with npcs = {npcs}\n",
    "Same number of PCs ({npcs}) for both integration and UMAP\n",
    "Integration is done using Seurat::IntegrateLayers() with method = \"{method}\"\n",
    "UMAP is run using Seurat::RunUMAP() with method = \"{umap.method}\" and metric = \"{metric}\"\n",
    "UMAP parameters: n.neighbors = {n.neighbors}, spread = {spread}, min.dist = {min.dist}\n",
    if (run_pca_umap) "UMAP is also run on PCA (non-integrated) obj\n" else "",
    "Clusters are determined using resolution(s) = {paste(vec_res, collapse = \", \")} ",
    "and algorithm = {algorithm} ({algo_label})\n",
    "Additional arguments: vars.to.regress = \"{vars_str}\", verbose = {verbose}\n",
    "All steps are executed with seed = {seed}."
  )

  cat(msg, "\n")

  #---------------------------------------------------------------------------
  # 1. SCTransform (normalization)
  #---------------------------------------------------------------------------
  set.seed(seed)
  obj <- SCTransform(
    obj,
    variable.features.n = n_features,
    seed.use            = seed,
    vars.to.regress     = vars.to.regress,
    verbose             = verbose
  )
  invisible(gc())

  DefaultAssay(obj) <- "SCT"

  #---------------------------------------------------------------------------
  # 1.1 Inject markers as SCT Pearson residuals - optional
  #---------------------------------------------------------------------------
  if (!is.null(add.markers)) {
    genes_use <- intersect(add.markers, rownames(obj))
    genes_use <- genes_use[!genes_use %in% VariableFeatures(obj)]
    n_genes   <- length(unique(genes_use))
    msg       <- glue("Adding {n_genes} genes as additional markers to scale.data")
    cat(msg, "\n")

    obj <- GetResidual(
      object        = obj,
      features      = genes_use,
      verbose       = verbose
    )
    
    DefaultAssay(obj) <- "SCT"
    
    VariableFeatures(obj) <- union(VariableFeatures(obj), genes_use)
  }

  #---------------------------------------------------------------------------
  # 2. PCA on SCT
  #---------------------------------------------------------------------------
  set.seed(seed)
  obj <- RunPCA(
    obj,
    npcs     = npcs,
    assay    = "SCT",
    seed.use = seed,
    verbose  = verbose
  )
  invisible(gc())

  #---------------------------------------------------------------------------
  # 3. Harmony integration on PCA
  #---------------------------------------------------------------------------
  set.seed(seed)
  obj <- IntegrateLayers(
    object         = obj,
    method         = method,
    orig.reduction = "pca",
    new.reduction  = "harmony",
    group.by.vars  = "sample_id",
    verbose        = verbose
  )
  invisible(gc())

  #---------------------------------------------------------------------------
  # 4. UMAP on PCA (non-integrated) - optional
  #---------------------------------------------------------------------------
  if (run_pca_umap) {
    set.seed(seed)
    obj <- RunUMAP(
      obj,
      reduction      = "pca",
      dims           = seq_len(npcs),
      umap.method    = umap.method,
      metric         = metric,
      spread         = spread,
      min.dist       = min.dist,
      reduction.name = "umap",
      seed.use       = seed,
      verbose        = verbose
    )
    invisible(gc())
  }

  #---------------------------------------------------------------------------
  # 5. UMAP on Harmony (integrated)
  #---------------------------------------------------------------------------
  set.seed(seed)
  obj <- RunUMAP(
    obj,
    reduction      = "harmony",
    dims           = seq_len(npcs),
    umap.method    = umap.method,
    metric         = metric,
    spread         = spread,
    min.dist       = min.dist,
    reduction.name = "umap.harmony",
    seed.use       = seed,
    verbose        = verbose
  )
  invisible(gc())

  #---------------------------------------------------------------------------
  # 6. Neighbors and clustering
  #---------------------------------------------------------------------------
  set.seed(seed)
  obj <- FindNeighbors(
    obj,
    reduction = "harmony",
    dims      = seq_len(npcs),
    verbose   = verbose
  )
  invisible(gc())

  for (cres in vec_res) {
    set.seed(seed)
    obj <- FindClusters(
      obj,
      resolution   = cres,
      algorithm    = algorithm,
      cluster.name = paste0("harmony_clusters.", cres),
      random.seed  = seed,
      verbose      = verbose
    )
    invisible(gc())
  }

  #---------------------------------------------------------------------------
  # 7. Sort clusters by size
  #---------------------------------------------------------------------------
  for (cres in vec_res) {
    set.seed(seed)
    cluster_sizes <- table(obj@meta.data[, paste0("harmony_clusters.", cres)])
    sorted_clusters <- names(sort(cluster_sizes, decreasing = TRUE))
    new_cluster_map <- setNames(seq_along(sorted_clusters) - 1, sorted_clusters)
    obj@meta.data[, paste0("harmony_clusters.", cres)] <- new_cluster_map[
      as.character(obj@meta.data[, paste0("harmony_clusters.", cres)])
    ]
    obj@meta.data[, paste0("harmony_clusters.", cres)] <- factor(
      obj@meta.data[, paste0("harmony_clusters.", cres)],
      levels = sort(unique(obj@meta.data[, paste0("harmony_clusters.", cres)]))
    )
  }

  return(obj)

  invisible(gc())
}
