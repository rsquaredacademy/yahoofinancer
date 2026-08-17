#' Symbol validation
#'
#' @title Symbol validation
#'
#' @description
#' Validate symbols before retrieving data. This function checks whether
#' the provided ticker strings are valid according to the Yahoo Finance API.
#'
#' @param symbol A character vector of one or more ticker strings, index or fund names (e.g., \code{c("AAPL", "MSFT")}).
#' @param index Deprecated. Use \code{symbol} instead.
#' @param return_logical A logical value indicating whether to return a named logical vector. If \code{FALSE} (default), returns a character vector containing only the valid symbols. If \code{TRUE}, returns a named logical vector indicating validation status (\code{TRUE}/\code{FALSE}) for each symbol.
#'
#' @return
#' If \code{return_logical = FALSE} (the default), a character vector of valid symbols.
#' If \code{return_logical = TRUE}, a named logical vector indicating validation status for each symbol.
#'
#' @examples
#' \dontrun{
#' validate("AAPL")
#' validate(c("AAPL", "NOTASTOCK", "MSFT"))
#' validate(c("AAPL", "NOTASTOCK", "MSFT"), return_logical = TRUE)
#' }
#'
#' @export
#'
validate <- function(symbol = NULL, index = NA, return_logical = FALSE) {
  if (!missing(index) && !is.null(index) && !all(is.na(index))) {
    warning("The 'index' parameter is deprecated. Please use 'symbol' instead.", call. = FALSE)
    if (missing(symbol) || is.null(symbol) || all(is.na(symbol))) {
      symbol <- index
    }
  }

  if (is.null(symbol) || length(symbol) == 0) {
    warning("Input 'symbol' is empty or missing.", call. = FALSE)
    return(if (return_logical) logical(0) else character(0))
  }

  if (!is.character(symbol)) {
    warning("Input 'symbol' must be a character vector.", call. = FALSE)
    return(if (return_logical) logical(0) else character(0))
  }

  # Filter out NAs but keep original order and length for logical return
  orig_symbol <- symbol
  
  if (!has_internet()) {
    message("No internet connection.")
    res <- rep(FALSE, length(orig_symbol))
    names(res) <- orig_symbol
    return(if (return_logical) res else character(0))
  }

  validate_single <- function(sym) {
    if (is.na(sym)) return(FALSE)
    if (nchar(trimws(sym)) == 0) return(FALSE)
    
    base_url <- 'https://query2.finance.yahoo.com'
    path     <- 'v6/finance/quote/validate'
    url      <- paste0(base_url, "/", path)
    qlist    <- list(symbols = sym)

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

    if (is.null(resp) || httr2::resp_is_error(resp)) return(FALSE)

    parsed <- tryCatch(
      httr2::resp_body_json(resp, simplifyVector = FALSE),
      error = function(e) list()
    )

    tryCatch({
      val <- parsed$symbolsValidation$result[[1]][[1]]
      if (is.null(val)) FALSE else as.logical(val)
    }, error = function(e) FALSE)
  }

  results <- vapply(orig_symbol, validate_single, FUN.VALUE = logical(1), USE.NAMES = TRUE)

  if (return_logical) {
    return(results)
  } else {
    valid_symbols <- names(results)[results & !is.na(names(results))]
    return(unname(valid_symbols))
  }
}
