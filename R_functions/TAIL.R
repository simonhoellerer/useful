#### TAIL.R ###
# This function is a simple utility to get the last few rows and columns of a
# matrix or data frame, similar to the base R `tail()` function but applied to
# both dimensions.

TAIL <- function(x, length = 5){
  return(x[(nrow(x) - length):nrow(x), (ncol(x) - length):ncol(x)])
}
