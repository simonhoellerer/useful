#### HEAD.R ###
# This function is a simple utility to get the first few rows and columns of a
# matrix or data frame, similar to the base R `head()` function but applied to
# both dimensions.

HEAD <- function(x, length = 5){
  return(x[1:length, 1:length])
}
