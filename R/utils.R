has_internet <- function() curl::has_internet()


flatten_list <- function(x) {
  if (is.null(x)) return(NULL)
  unlist(lapply(x, function(m) if (is.null(m)) NA else m))
}

to_snake_case <- function(x) {
  x <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  x <- gsub("([A-Z]+)([A-Z][a-z])", "\\1_\\2", x)
  tolower(x)
}

parse_chart_data <- function(data, symbol = NA_character_) {
  if (is.null(data) || is.null(data$timestamp) || length(data$timestamp) == 0) {
    return(tibble::tibble(
      symbol = character(),
      date = as.POSIXct(integer(), origin = "1970-01-01", tz = "UTC"),
      open = numeric(),
      high = numeric(),
      low = numeric(),
      close = numeric(),
      adj_close = numeric(),
      volume = numeric()
    ))
  }

  indicators <- data$indicators$quote[[1]]

  date   <- lubridate::as_datetime(unlist(data$timestamp))
  volume <- flatten_list(indicators$volume)
  high   <- flatten_list(indicators$high)
  low    <- flatten_list(indicators$low)
  open   <- flatten_list(indicators$open)
  close  <- flatten_list(indicators$close)
  
  adj_close <- data$indicators$adjclose[[1]]$adjclose
  
  if (!is.null(adj_close)) {
    null_adj <- vapply(adj_close, is.null, logical(1))
    adj_close[null_adj] <- NA
    adj_close <- unlist(adj_close)
    if (length(adj_close) != length(date)) {
      adj_close <- close
    }
  } else {
    adj_close <- close
  }

  res <- tibble::tibble(
    symbol = symbol,
    date = date,
    open = as.numeric(open),
    high = as.numeric(high),
    low = as.numeric(low),
    close = as.numeric(close),
    adj_close = as.numeric(adj_close),
    volume = as.numeric(volume)
  )

  return(res)
}
