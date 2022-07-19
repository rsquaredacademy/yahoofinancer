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