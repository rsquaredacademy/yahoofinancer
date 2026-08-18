#' Currencies
#'
#' List of currencies Yahoo Finance supports.
#'
#' @examples
#' \donttest{
#' get_currencies()
#' }
#'
#' @return Symbol, short and long name of the currencies.
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
#' @description Retrieve live market overview snapshots across global benchmark indices, commodities, currencies, and futures.
#' @param as_tibble Logical; if TRUE (default), returns a tidy tibble. If FALSE, returns the raw nested list.
#' @return A tibble of market quotes (if as_tibble = TRUE) or a nested list (if as_tibble = FALSE).
#' @export
#' @examples
#' \dontrun{
#' # Tidy tibble output (default)
#' market_df <- get_market_summary()
#'
#' # Raw list output
#' market_list <- get_market_summary(as_tibble = FALSE)
#' }
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

#' Trending securities
#'
#' List of trending securities for specific country.
#'
#' @param country Name of the country.
#' @param count Number of securities.
#'
#' @return Securities trending in the country.
#'
#' @examples
#' \donttest{
#' get_trending()
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

#' Currency converter
#'
#' Retrieve current conversion rate between two currencies as well as historical rates.
#'
#' @param from Currency to convert from.
#' @param to Currency to convert to.
#' @param start Specific starting date. \code{String} or \code{date} object in \code{yyyy-mm-dd} format.
#' @param end Specific ending date. \code{String} or \code{date} object in \code{yyyy-mm-dd} format.
#' @param period Length of time. Defaults to \code{'ytd'} Valid values are:
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
#' @param interval Time between data points. Defaults to \code{'1d'} Valid values are:
#' \itemize{
#' \item \code{'1h'}
#' \item \code{'1d'}
#' \item \code{'5d'}
#' \item \code{'1wk'}
#' \item \code{'1mo'}
#' \item \code{'3mo'}
#' }
#'
#' @return  A \code{data.frame}.
#'
#' @examples
#' \donttest{
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


