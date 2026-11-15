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
#' @param return_logical A logical value indicating whether to return a named logical vector.
#'   If \code{FALSE} (default), returns a character vector containing only the valid symbols.
#'   If \code{TRUE}, returns a named logical vector indicating validation status (\code{TRUE}/\code{FALSE})
#'   for each symbol.
#'
#' @return
#' If \code{return_logical = FALSE} (the default), a character vector of valid symbols.
#' If \code{return_logical = TRUE}, a named logical vector indicating validation status for each symbol.
#' Matching is case-insensitive; returned symbols and names retain the caller's
#' spelling and order, including dots.
#'
#' @examples
#' \dontrun{
#' validate("AAPL")
#' validate(c("AAPL", "NOTASTOCK", "MSFT"))
#' validate(c("AAPL", "NOTASTOCK", "MSFT"), return_logical = TRUE)
#' }
#'
#' @family validation
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

  orig_symbol <- symbol

  if (!has_internet()) {
    message("No internet connection.")
    res <- rep(FALSE, length(orig_symbol))
    names(res) <- orig_symbol
    return(if (return_logical) res else character(0))
  }

  symbols_to_query <- unique(orig_symbol[!is.na(orig_symbol) & nchar(trimws(orig_symbol)) > 0])

  if (length(symbols_to_query) == 0) {
    res <- rep(FALSE, length(orig_symbol))
    names(res) <- orig_symbol
    return(if (return_logical) res else character(0))
  }

  url <- "https://query2.finance.yahoo.com/v6/finance/quote/validate"
  qlist <- list(symbols = paste(symbols_to_query, collapse = ","))

  parsed <- api_request(url, qlist)
  if (is.null(parsed)) {
    res <- rep(FALSE, length(orig_symbol))
    names(res) <- orig_symbol
    return(if (return_logical) res else character(0))
  }

  valid_map <- list()
  raw_res <- parsed$symbolsValidation$result

  if (!is.null(raw_res)) {
    # Each result element is an object keyed by the exact symbol Yahoo
    # validated (symbols may contain dots, e.g. "VOD.L"). Canonicalize case
    # only; never infer identity from flattened names or response order.
    for (entry in raw_res) {
      if (!is.list(entry) && !is.logical(entry)) next
      keys <- names(entry)
      if (is.null(keys)) next
      for (k in keys) {
        if (nzchar(k)) {
          valid_map[[toupper(k)]] <- isTRUE(as.logical(entry[[k]]))
        }
      }
    }
  }

  res <- rep(FALSE, length(orig_symbol))
  names(res) <- orig_symbol

  for (i in seq_along(orig_symbol)) {
    s <- orig_symbol[i]
    if (!is.na(s) && isTRUE(valid_map[[toupper(s)]])) {
      res[i] <- TRUE
    }
  }

  if (return_logical) {
    res
  } else {
    valid_symbols <- orig_symbol[res & !is.na(orig_symbol)]
    unname(valid_symbols)
  }
}
