#' Symbol validation
#'
#' Validate symbols before retrieving data.
#'
#' @param symbol Ticker, index or fund name.
#' @param index Deprecated. Use \code{symbol} instead.
#'
#' @examples
#' validate("aapl")
#' validate("aapls")
#'
#' @export
#'
validate <- function(symbol = NA, index = NA) {
  if (!is.na(index)) {
    warning("The 'index' parameter is deprecated. Please use 'symbol' instead.", call. = FALSE)
    if (is.na(symbol)) symbol <- index
  }

  if (is.na(symbol)) return(invisible(NULL))

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
    parsed$symbolsValidation$result[[1]][[1]]
  }

}

flatten_list <- function(x) {
  if (is.null(x)) return(NULL)
  unlist(lapply(x, function(m) if (is.null(m)) NA else m))
}

