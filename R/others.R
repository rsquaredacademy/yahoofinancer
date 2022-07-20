#' Currencies
#'
#' List of currencies Yahoo Finance supports
#'
#' @examples
#' get_currencies()
#'
#' @export
#'
get_currencies <- function() {
  base_url <- 'https://query1.finance.yahoo.com'
  path     <- 'v1/finance/currencies'
  url      <- modify_url(url = base_url, path = path)
  resp     <- GET(url)
  parsed   <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  data <-
    parsed %>%
    use_series(currencies) %>%
    use_series(result)

  data.frame(
    short_name = map_chr(data, 'shortName'),
    long_name = map_chr(data, 'longName'),
    symbol = map_chr(data, 'symbol'),
    local_long_name = map_chr(data, 'localLongName')
  )
}


#' Market Summary
#'
#' List of relevant exchanges for specific country
#'
#' @param country Name of country
#'
#' @examples
#' get_market_summary()
#'
#' @export
#'
get_market_summary <- function(country = 'US') {
  base_url <- 'https://query1.finance.yahoo.com'
  path     <- 'v6/finance/quote/marketSummary'
  url      <- modify_url(url = base_url, path = path)
  qlist    <- list(region = country)
  resp     <- GET(url, query = qlist)
  parsed   <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  parsed %>%
    use_series(marketSummaryResponse) %>%
    use_series(result)
}

#' Trending securities
#'
#' List of trending securities for specific country
#'
#' @param country Name of country
#' @param count Number of securities
#'
#' @examples
#' get_trending()
#'
#' @export
#'
get_trending <- function(country = 'US', count = 10) {
  base_url  <- 'https://query1.finance.yahoo.com'
  path      <- 'v1/finance/trending/'
  end_point <- paste0(path, country)
  url       <- modify_url(url = base_url, path = end_point)
  qlist     <- list(count = count)
  resp      <- GET(url, query = qlist)
  parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  data <-
    parsed %>%
    use_series(finance) %>%
    use_series(result)

  if (length(data) > 0) {
    data %>%
      extract2(1) %>%
      use_series(quote) %>%
      map_chr('symbol')
  } else {
    message('No trending securities.')
  }

}

#' Currency converter
#'
#' Retrieve current conversion rate between two currencies as well as historical rates
#'
#' @param from Currency to convert from
#' @param to Currency to convert to
#' @param start Specific starting date
#' @param end Specific ending date
#' @param period Length of time
#' @param interval Time between data points
#'    
#' @examples
#' currency_converter()
#' currency_converter(from = 'GBP', to = 'USD', start = '2022-07-01', end = '2022-07-10', interval = '1h')
#'
#' @export
#'
currency_converter <- function(from = 'EUR', to = 'USD', start = NULL, end = NULL, period = 'ytd', interval = '1d') {

  if (!is.null(start)) {
    start_date <- as.numeric(as.POSIXct(ymd(start)))
  }

  if (!is.null(end)) {
    end_date <- as.numeric(as.POSIXct(ymd(end)))
  }

  base_url    <- 'https://query1.finance.yahoo.com'
  path        <- 'v8/finance/chart/'
  cors_domain <- 'finance.yahoo.com'
  end_point   <- paste0(path, from, to, '=X')
  url         <- modify_url(url = base_url, path = end_point)

  if (!is.null(start) && !is.null(end)) {
    qlist <- list(period1 = start_date, period2 = end_date, interval = interval, corsDomain = cors_domain)
  } else if (!is.null(start) && is.null(end)) {
    qlist <- list(period1 = start_date, period2 = round(as.numeric(as.POSIXct(now()))), interval = interval, corsDomain = cors_domain)
  } else {
    qlist <- list(range = period, interval = interval, corsDomain = cors_domain)
  }

  resp      <- GET(url, query = qlist)
  parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  parsed

  data <-
    parsed %>%
    use_series(chart) %>%
    use_series(result) %>%
    extract2(1)

  indicators <-
    data %>%
    use_series(indicators) %>%
    use_series(quote) %>%
    extract2(1)

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
    adj_close <-
      data %>%
      use_series(indicators) %>%
      use_series(adjclose) %>%
      extract2(1) %>%
      use_series(adjclose) %>%
      unlist()

    result$adj_close <- adj_close

  }

  subset(result, !is.na(volume))

}

#' Currency summary
#'
#' Summary info
#'
#' @param from Currency to convert from
#' @param to Currency to convert to
#'    
#' @examples
#' currency_summary('GBP', 'USD')
#'
#' @export
#'
currency_summary <- function(from = 'USD', to = 'INR') {

  base_url    <- 'https://query2.finance.yahoo.com'
  path        <- 'v7/finance/quote'
  cors_domain <- 'finance.yahoo.com'
  url         <- modify_url(url = base_url, path = path)
  qlist       <- list(symbols = paste0(from, to, '=X'), corsDomain = cors_domain)
  resp        <- GET(url, query = qlist)
  parsed      <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

  parsed %>%
    use_series(quoteResponse) %>%
    use_series(result) %>%
    extract2(1)
}

flatten_list <- function(x) {
  unlist(lapply(x, function(m) ifelse(is.null(m), NA, m)))
}