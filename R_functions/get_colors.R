### get_colors.r ###
# Function to generate a named vector of colors for clusters or samples from
# a specified column in a data frame, using a specified color palette.
# The function supports both categorical palettes (e.g., "alphabet") and
# continuous palettes (e.g., "Set1"). It automatically handles cases where the
# number of clusters exceeds the maximum number of colors in the palette by
# generating an extended palette using colorRampPalette.

get_colors <- function(input, column, palette = "alphabet") {

  # get clusters
  clusters <- unique(unlist(input[, column]))
  n_clusters <- length(clusters)

  # get colors
  if (palette == "alphabet") {
    if (n_clusters > 26) {
      cols <- colorRampPalette(pals::alphabet())(n_clusters)
    } else {
      cols <- pals::alphabet(n_clusters)
    }
  } else if (palette == "alphabet2") {
    if (n_clusters > 26) {
      cols <- colorRampPalette(pals::alphabet2())(n_clusters)
    } else {
      cols <- pals::alphabet2(n_clusters)
    }
  } else {
    if (n_clusters > 8) {
      cols <- colorRampPalette(brewer.pal(12, palette))(n_clusters)
    } else {
      cols <- brewer.pal(n_clusters, palette)
    }
  }

  # name colors
  names(cols) <- as.character(clusters)
  return(cols)
}
