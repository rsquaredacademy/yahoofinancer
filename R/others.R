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
  url      <- modify_url(url = base_url, path = path)

  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  resp     <- GET(url)
  parsed   <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                       simplifyVector = FALSE)

  if (http_error(resp)) {

    message(
      cat(
        "Yahoo Finance API request failed", '\n',
        paste('Status:', status_code(resp)), '\n',
        paste('Type:', http_status(resp)$category), '\n',
        paste('Mesage:', parsed$quoteSummary$error$code), '\n',
        paste('Description:', parsed$quoteSummary$error$description, '\n'),
        sep = ''
      )
    )

    return(invisible(NULL))
  } else {

    data <-
      parsed %>%
      use_series(currencies) %>%
      use_series(result)

    data.frame(
      short_name      = map_chr(data, 'shortName'),
      long_name       = map_chr(data, 'longName'),
      symbol          = map_chr(data, 'symbol'),
      local_long_name = map_chr(data, 'localLongName')
    )

  }
}


#' Market Summary
#'
#' Summary info of relevant exchanges for specific country.
#'
#' @param country Name of the country.
#'
#' @return A \code{data.frame}.
#'
#' @examples
#' \donttest{
#' get_market_summary(country = 'US')
#' }
#'
#' @export
#'
get_market_summary <- function(country = 'US') {

  base_url <- 'https://query1.finance.yahoo.com'
  path     <- 'v6/finance/quote/marketSummary'
  url      <- modify_url(url = base_url, path = path)
  qlist    <- list(region = country)

  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  resp     <- GET(url, query = qlist)
  parsed   <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                       simplifyVector = FALSE)

  if (http_error(resp)) {

    message(
      cat(
        "Yahoo Finance API request failed", '\n',
        paste('Status:', status_code(resp)), '\n',
        paste('Type:', http_status(resp)$category), '\n',
        paste('Mesage:', parsed$quoteSummary$error$code), '\n',
        paste('Description:', parsed$quoteSummary$error$description, '\n'),
        sep = ''
      )
    )

    return(invisible(NULL))
  } else {

    parsed %>%
      use_series(marketSummaryResponse) %>%
      use_series(result)

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
  url       <- modify_url(url = base_url, path = end_point)
  qlist     <- list(count = count)

  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  resp      <- GET(url, query = qlist)
  parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                        simplifyVector = FALSE)

  if (http_error(resp)) {

    message(
      cat(
        "Yahoo Finance API request failed", '\n',
        paste('Status:', status_code(resp)), '\n',
        paste('Type:', http_status(resp)$category), '\n',
        paste('Mesage:', parsed$quoteSummary$error$code), '\n',
        paste('Description:', parsed$quoteSummary$error$description, '\n'),
        sep = ''
      )
    )

    return(invisible(NULL))
  } else {

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
  url         <- modify_url(url = base_url, path = end_point)

  if (!is.null(start) && !is.null(end)) {
    qlist <- list(period1 = start_date, period2 = end_date, interval = interval, corsDomain = cors_domain)
  } else if (!is.null(start) && is.null(end)) {
    qlist <- list(period1 = start_date, period2 = round(as.numeric(as.POSIXct(now("UTC")))), interval = interval, corsDomain = cors_domain)
  } else {
    qlist <- list(range = period, interval = interval, corsDomain = cors_domain)
  }

  if (!curl::has_internet()) {
    message("No internet connection.")
    return(invisible(NULL))
  }

  resp      <- GET(url, query = qlist)
  parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                        simplifyVector = FALSE)

  if (http_error(resp)) {

    message(
      cat(
        "Yahoo Finance API request failed", '\n',
        paste('Status:', status_code(resp)), '\n',
        paste('Type:', http_status(resp)$category), '\n',
        paste('Mesage:', parsed$quoteSummary$error$code), '\n',
        paste('Description:', parsed$quoteSummary$error$description, '\n'),
        sep = ''
      )
    )

    return(invisible(NULL))
  } else {

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

  return(subset(result, !is.na(volume)))

  }

}


