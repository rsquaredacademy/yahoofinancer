#' Get Supported Currencies
#'
#' @description
#' Retrieves the list of currencies supported by Yahoo Finance.
#'
#' @return A \code{data.frame} with 4 columns:
#'   \code{short_name} (character), \code{long_name} (character),
#'   \code{symbol} (character), \code{local_long_name} (character).
#'   Returns \code{invisible(NULL)} on network failure.
#'
#' @family currency
#'
#' @examples
#' \dontrun{
#' get_currencies()
#' }
#'
#' @export
#'
get_currencies <- function() {
  base_url <- 'https://query1.finance.yahoo.com'
  path     <- 'v1/finance/currencies'
  url      <- paste0(base_url, "/", path)

  if (!has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, "yahoofinancer")
  req <- httr2::req_retry(req, max_tries = 4, backoff = function(re_try) 2^re_try)
  req <- httr2::req_timeout(req, 15)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) NULL
  )

  if (is.null(resp)) return(invisible(NULL))

  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) list()
  )

  if (httr2::resp_is_error(resp)) {
    status <- httr2::resp_status(resp)
    cat(
      "Yahoo Finance API request failed", '\n',
      paste('Status:', status), '\n',
      paste('Type:', if (status >= 400 && status < 500) "Client error" else "Server error"), '\n',
      paste('Mesage:', parsed$quoteSummary$error$code), '\n',
      paste('Description:', parsed$quoteSummary$error$description, '\n'),
      sep = ''
    )
    return(invisible(NULL))
  } else {

    data <- parsed$currencies$result

    data.frame(
      short_name      = map_chr(data, 'shortName'),
      long_name       = map_chr(data, 'longName'),
      symbol          = map_chr(data, 'symbol'),
      local_long_name = map_chr(data, 'localLongName')
    )

  }
}


#' @title Get Real-Time Market Summary
#'
#' @description
#' Retrieve live market overview snapshots across global benchmark indices,
#' commodities, currencies, and futures.
#'
#' @param as_tibble Logical; if \code{TRUE} (default), returns a tidy tibble.
#'   If \code{FALSE}, returns the raw nested list from the API.
#'
#' @return If \code{as_tibble = TRUE}, a \code{\link[tibble]{tibble}} with 9 columns:
#'   \code{symbol}, \code{short_name}, \code{regular_market_price},
#'   \code{regular_market_change}, \code{regular_market_change_percent},
#'   \code{regular_market_previous_close}, \code{market_state},
#'   \code{exchange}, \code{market_time} (POSIXct, UTC).
#'   If \code{as_tibble = FALSE}, a nested list.
#'   Returns an empty tibble (or \code{invisible(NULL)}) on failure.
#'
#' @family market data
#'
#' @examples
#' \dontrun{
#' # Tidy tibble output (default)
#' market_df <- get_market_summary()
#'
#' # Raw list output
#' market_list <- get_market_summary(as_tibble = FALSE)
#' }
#'
#' @export
get_market_summary <- function(as_tibble = TRUE) {

  if (!is.logical(as_tibble) || length(as_tibble) != 1 || is.na(as_tibble)) {
    stop("`as_tibble` must be a single logical value (TRUE or FALSE).", call. = FALSE)
  }

  empty_tibble <- function() {
    tibble::tibble(
      symbol = character(),
      short_name = character(),
      regular_market_price = numeric(),
      regular_market_change = numeric(),
      regular_market_change_percent = numeric(),
      regular_market_previous_close = numeric(),
      market_state = character(),
      exchange = character(),
      market_time = as.POSIXct(integer(), origin = "1970-01-01", tz = "UTC")
    )
  }

  base_url <- 'https://query1.finance.yahoo.com'
  path     <- 'v6/finance/quote/marketSummary'
  url      <- paste0(base_url, "/", path)
  qlist    <- list(region = 'US')

  if (!has_internet()) {
    message("No internet connection.")
    if (as_tibble) return(empty_tibble()) else return(invisible(NULL))
  }

  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, "yahoofinancer")
  req <- do.call(httr2::req_url_query, c(list(req), qlist))
  req <- httr2::req_retry(req, max_tries = 4, backoff = function(re_try) 2^re_try)
  req <- httr2::req_timeout(req, 15)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) NULL
  )

  if (is.null(resp)) {
    if (as_tibble) return(empty_tibble()) else return(invisible(NULL))
  }

  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) list()
  )

  if (httr2::resp_is_error(resp)) {
    status <- httr2::resp_status(resp)
    cat(
      "Yahoo Finance API request failed", '\n',
      paste('Status:', status), '\n',
      paste('Type:', if (status >= 400 && status < 500) "Client error" else "Server error"), '\n',
      paste('Mesage:', parsed$quoteSummary$error$code), '\n',
      paste('Description:', parsed$quoteSummary$error$description, '\n'),
      sep = ''
    )
    if (as_tibble) return(empty_tibble()) else return(invisible(NULL))
  } else {
    data <- parsed$marketSummaryResponse$result
    
    if (as_tibble) {
      if (length(data) == 0) {
        return(empty_tibble())
      }
      
      safe_extract_scalar_char <- function(x, name, default = NA_character_) {
        val <- x[[name]]
        if (is.null(val)) return(default)
        as.character(val)
      }
      
      safe_extract_raw_numeric <- function(x, name, default = NA_real_) {
        val <- x[[name]]
        if (is.null(val) || is.null(val$raw)) return(default)
        as.numeric(val$raw)
      }
      
      res <- tibble::tibble(
        symbol = vapply(data, safe_extract_scalar_char, name = "symbol", FUN.VALUE = character(1)),
        short_name = vapply(data, safe_extract_scalar_char, name = "shortName", FUN.VALUE = character(1)),
        regular_market_price = vapply(data, safe_extract_raw_numeric, name = "regularMarketPrice", FUN.VALUE = numeric(1)),
        regular_market_change = vapply(data, safe_extract_raw_numeric, name = "regularMarketChange", FUN.VALUE = numeric(1)),
        regular_market_change_percent = vapply(data, safe_extract_raw_numeric, name = "regularMarketChangePercent", FUN.VALUE = numeric(1)),
        regular_market_previous_close = vapply(data, safe_extract_raw_numeric, name = "regularMarketPreviousClose", FUN.VALUE = numeric(1)),
        market_state = vapply(data, safe_extract_scalar_char, name = "marketState", FUN.VALUE = character(1)),
        exchange = vapply(data, safe_extract_scalar_char, name = "exchange", FUN.VALUE = character(1)),
        market_time = as.POSIXct(vapply(data, safe_extract_raw_numeric, name = "regularMarketTime", FUN.VALUE = numeric(1)), origin = "1970-01-01", tz = "UTC")
      )
      
      return(res)
    } else {
      if (length(data) == 0) return(list())
      return(data)
    }
  }
}

#' Get Trending Securities
#'
#' @description
#' Retrieves the list of currently trending securities for a specific
#' region from Yahoo Finance.
#'
#' @param country ISO 3166-1 alpha-2 region code (e.g., \code{"US"},
#'   \code{"GB"}, \code{"IN"}). Defaults to \code{"US"}.
#' @param count Maximum number of trending securities to return.
#'   Defaults to \code{10}.
#'
#' @return A character vector of trending ticker symbols.
#'   Returns \code{invisible(NULL)} on network failure or if no data
#'   is available (with a message).
#'
#' @family market data
#'
#' @examples
#' \dontrun{
#' get_trending()
#' get_trending(country = "GB", count = 5)
#' }
#'
#' @export
#'
get_trending <- function(country = 'US', count = 10) {

  base_url  <- 'https://query1.finance.yahoo.com'
  path      <- 'v1/finance/trending/'
  end_point <- paste0(path, country)
  url       <- paste0(base_url, "/", end_point)
  qlist     <- list(count = count)

  if (!has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, "yahoofinancer")
  req <- do.call(httr2::req_url_query, c(list(req), qlist))
  req <- httr2::req_retry(req, max_tries = 4, backoff = function(re_try) 2^re_try)
  req <- httr2::req_timeout(req, 15)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) NULL
  )

  if (is.null(resp)) return(invisible(NULL))

  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) list()
  )

  if (httr2::resp_is_error(resp)) {
    status <- httr2::resp_status(resp)
    cat(
      "Yahoo Finance API request failed", '\n',
      paste('Status:', status), '\n',
      paste('Type:', if (status >= 400 && status < 500) "Client error" else "Server error"), '\n',
      paste('Mesage:', parsed$quoteSummary$error$code), '\n',
      paste('Description:', parsed$quoteSummary$error$description, '\n'),
      sep = ''
    )
    return(invisible(NULL))
  } else {

    data <- parsed$finance$result

    if (length(data) > 0) {
      data %>%
        extract2(1) %>%
        use_series(quote) %>%
        map_chr('symbol')
    } else {
      message('No trending securities.')
    }

  }

}

#' Currency Converter
#'
#' @description
#' Retrieve current and historical exchange rates between two currencies
#' via the Yahoo Finance chart API.
#'
#' @param from ISO 4217 three-letter currency code to convert from
#'   (e.g., \code{"EUR"}, \code{"GBP"}). Defaults to \code{"EUR"}.
#' @param to ISO 4217 three-letter currency code to convert to
#'   (e.g., \code{"USD"}, \code{"JPY"}). Defaults to \code{"USD"}.
#' @param start Specific starting date. \code{String} or \code{Date} object
#'   in \code{"YYYY-MM-DD"} format.
#' @param end Specific ending date. \code{String} or \code{Date} object
#'   in \code{"YYYY-MM-DD"} format.
#' @param period Length of time. Defaults to \code{'ytd'}. Valid values:
#' \itemize{
#' \item \code{'1d'}
#' \item \code{'5d'}
#' \item \code{'1mo'}
#' \item \code{'3mo'}
#' \item \code{'6mo'}
#' \item \code{'1y'}
#' \item \code{'2y'}
#' \item \code{'5y'}
#' \item \code{'10y'}
#' \item \code{'ytd'}
#' \item \code{'max'}
#' }
#' @param interval Time between data points. Defaults to \code{'1d'}. Valid values:
#' \itemize{
#' \item \code{'1h'}
#' \item \code{'1d'}
#' \item \code{'5d'}
#' \item \code{'1wk'}
#' \item \code{'1mo'}
#' \item \code{'3mo'}
#' }
#'
#' @return A \code{data.frame} with columns: \code{date} (POSIXct),
#'   \code{high}, \code{low}, \code{open}, \code{close}, \code{volume}
#'   (all numeric), and conditionally \code{adj_close} (numeric, present
#'   for daily and longer intervals). Rows with \code{NA} volume are
#'   excluded. Returns \code{invisible(NULL)} on network failure.
#'
#' @family currency
#'
#' @examples
#' \dontrun{
#' currency_converter('GBP', 'USD', '2022-07-01', '2022-07-10')
#' currency_converter('GBP', 'USD', period = '1mo', interval = '1d')
#' }
#'
#' @export
#'
currency_converter <- function(from = 'EUR', to = 'USD', start = NULL, end = NULL, period = 'ytd', interval = '1d') {

  if (!is.null(start)) {
    start_date <- as.numeric(as.POSIXct(ymd(start, tz = "UTC"), tz = "UTC"))
  }

  if (!is.null(end)) {
    end_date <- as.numeric(as.POSIXct(ymd(end, tz = "UTC"), tz = "UTC"))
  }

  base_url    <- 'https://query1.finance.yahoo.com'
  path        <- 'v8/finance/chart/'
  cors_domain <- 'finance.yahoo.com'
  end_point   <- paste0(path, from, to, '=X')
  url         <- paste0(base_url, "/", end_point)

  if (!is.null(start) && !is.null(end)) {
    qlist <- list(period1 = start_date, period2 = end_date, interval = interval, corsDomain = cors_domain)
  } else if (!is.null(start) && is.null(end)) {
    qlist <- list(period1 = start_date, period2 = round(as.numeric(as.POSIXct(now("UTC")))), interval = interval, corsDomain = cors_domain)
  } else {
    qlist <- list(range = period, interval = interval, corsDomain = cors_domain)
  }

  if (!has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, "yahoofinancer")
  req <- do.call(httr2::req_url_query, c(list(req), qlist))
  req <- httr2::req_retry(req, max_tries = 4, backoff = function(re_try) 2^re_try)
  req <- httr2::req_timeout(req, 15)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) NULL
  )

  if (is.null(resp)) return(invisible(NULL))

  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) list()
  )

  if (httr2::resp_is_error(resp)) {
    status <- httr2::resp_status(resp)
    cat(
      "Yahoo Finance API request failed", '\n',
      paste('Status:', status), '\n',
      paste('Type:', if (status >= 400 && status < 500) "Client error" else "Server error"), '\n',
      paste('Mesage:', parsed$quoteSummary$error$code), '\n',
      paste('Description:', parsed$quoteSummary$error$description, '\n'),
      sep = ''
    )
    return(invisible(NULL))
  } else {

  data <- parsed$chart$result[[1]]

  indicators <- data$indicators$quote[[1]]

  result <- data.frame(
    date   = as_datetime(unlist(data$timestamp)),
    high   = flatten_list(indicators$high),
    low    = flatten_list(indicators$low),
    open   = flatten_list(indicators$open),
    close  = flatten_list(indicators$close),
    volume = flatten_list(indicators$volume)
  )

  intervals <- c('1d', '5d', '1wk', '1mo', '3mo')

  if (interval %in% intervals) {
    adj_close <- data$indicators$adjclose[[1]]$adjclose
    if (!is.null(adj_close) && length(adj_close) > 0) {
      null_adj <- vapply(adj_close, is.null, logical(1))
      adj_close[null_adj] <- NA
      result$adj_close <- unlist(adj_close)
    }
  }

  return(subset(result, !is.na(volume)))

  }

}


