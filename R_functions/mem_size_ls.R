### mem_size_ls.R ###

# Function to list the sizes of objects in the global environment,
# sorted by size.

mem_size_ls <- function(n = 5) {
  env = .GlobalEnv
  obj_names <- ls(envir = env)

  obj_sizes <- sapply(
    obj_names,
    function(x) object.size(get(x, envir = env)),
    simplify = TRUE
  )

  temp <- data.frame(
    object = names(obj_sizes),
    MB = round(obj_sizes / 1024^2, 1)
  )
  
  temp <- temp[order(-temp$MB), ]
  temp$object <- NULL
  head(temp, n = n)
}
