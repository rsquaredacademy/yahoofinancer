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

  date <- lubridate::as_datetime(unlist(data$timestamp))
  n_obs <- length(date)

  indicators <- if (!is.null(data$indicators$quote) && length(data$indicators$quote) > 0) {
    data$indicators$quote[[1]]
  } else {
    list()
  }

  pad_or_flatten <- function(x, n) {
    flat <- flatten_list(x)
    if (is.null(flat) || length(flat) == 0) {
      return(rep(NA_real_, n))
    }
    if (length(flat) != n) {
      length(flat) <- n
    }
    as.numeric(flat)
  }

  volume <- pad_or_flatten(indicators$volume, n_obs)
  high   <- pad_or_flatten(indicators$high, n_obs)
  low    <- pad_or_flatten(indicators$low, n_obs)
  open   <- pad_or_flatten(indicators$open, n_obs)
  close  <- pad_or_flatten(indicators$close, n_obs)

  adj_close <- if (!is.null(data$indicators$adjclose) && length(data$indicators$adjclose) > 0) {
    data$indicators$adjclose[[1]]$adjclose
  } else {
    NULL
  }

  if (!is.null(adj_close)) {
    null_adj <- vapply(adj_close, is.null, logical(1))
    adj_close[null_adj] <- NA
    adj_close <- as.numeric(unlist(adj_close))
    if (length(adj_close) != n_obs) {
      warning("Adjusted close length does not match timestamps; falling back to close.", call. = FALSE)
      adj_close <- close
    }
  } else {
    adj_close <- close
  }

  res <- tibble::tibble(
    symbol = symbol,
    date = date,
    open = open,
    high = high,
    low = low,
    close = close,
    adj_close = adj_close,
    volume = volume
  )

  return(res)
}
