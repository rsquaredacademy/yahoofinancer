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

  url   <- 'https://query2.finance.yahoo.com/v6/finance/quote/validate'
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
    vals <- unlist(raw_res)
    clean_names <- sub("^.*\\.", "", names(vals))
    matching_names <- intersect(symbols_to_query, clean_names)
    if (length(matching_names) > 0) {
      for (i in seq_along(vals)) {
        nm <- clean_names[i]
        valid_map[[nm]] <- isTRUE(as.logical(vals[i]))
      }
    } else if (length(vals) == length(symbols_to_query)) {
      for (i in seq_along(symbols_to_query)) {
        valid_map[[symbols_to_query[i]]] <- isTRUE(as.logical(vals[i]))
      }
    }
  }

  res <- rep(FALSE, length(orig_symbol))
  names(res) <- orig_symbol

  for (i in seq_along(orig_symbol)) {
    s <- orig_symbol[i]
    if (!is.na(s) && isTRUE(valid_map[[s]])) {
      res[i] <- TRUE
    }
  }

  if (return_logical) {
    return(res)
  } else {
    valid_symbols <- orig_symbol[res & !is.na(orig_symbol)]
    return(unname(valid_symbols))
  }
}
