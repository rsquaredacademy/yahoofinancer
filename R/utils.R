has_internet <- function() curl::has_internet()
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
  url      <- paste0(base_url, "/", path)
  qlist    <- list(symbols = symbol)

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
    parsed$symbolsValidation$result[[1]][[1]]
  }

}

flatten_list <- function(x) {
  if (is.null(x)) return(NULL)
  unlist(lapply(x, function(m) if (is.null(m)) NA else m))
}
