has_internet <- function() curl::has_internet()


flatten_list <- function(x) {
  if (is.null(x)) return(NULL)
  unlist(lapply(x, function(m) if (is.null(m)) NA else m))
}
