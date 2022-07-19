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

