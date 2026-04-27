### scale_dotplot.R ###

# Scale for dot plots from red (high) to blue (low) with a light gray midpoint

scale_dotplot <- function() {
  scale_colour_gradient2(
    high = "#C1272D",
    mid = "gray90",
    low = "darkblue"
  )
}
