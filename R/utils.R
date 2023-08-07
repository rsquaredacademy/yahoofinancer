#' Symbol validation
#'
#' Validate symbols before retrieving data.
#'
#' @param symbol Ticker, index or fund name.
#'
#' @examples
#' validate("aapl")
#' validate("aapls")
#'
#' @export
#'
validate <- function(symbol = NULL) {

  base_url <- 'https://query2.finance.yahoo.com'
  path     <- 'v6/finance/quote/validate'
  url      <- modify_url(url = base_url, path = path)
  qlist    <- list(symbols = symbol)

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
      use_series(symbolsValidation) %>%
      use_series(result) %>%
      extract2(1) %>%
      extract2(1)
  }

}

flatten_list <- function(x) {
  unlist(lapply(x, function(m) ifelse(is.null(m), NA, m)))
}
