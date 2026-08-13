#' Download Historical Prices
#'
#' @description
#' Fetches historical price data for single or multiple tickers.
#'
#' @param tickers Character vector of stock symbols.
#' @param start Date or character string representing the start date (`YYYY-MM-DD`).
#' @param end Date or character string representing the end date (`YYYY-MM-DD`).
#' @param interval Time between data points (e.g., "1d", "1wk", "1mo").
#'
#' @return A `tibble` of historical prices with `symbol` as the first column.
#'
#' @examples
#' \donttest{
#' yf_download_prices("AAPL", start = "2023-01-01", end = "2023-01-10")
#' yf_download_prices(c("AAPL", "MSFT"), interval = "1mo")
#' }
#'
#' @export
yf_download_prices <- function(tickers, start = NULL, end = NULL, interval = "1d") {
  results <- lapply(tickers, function(ticker) {
    tryCatch({
      obj <- Ticker$new(ticker)
      res <- obj$get_history(start = start, end = end, interval = interval)
      if (is.null(res) || nrow(res) == 0) return(NULL)
      
      res$symbol <- ticker
      cols <- c("symbol", setdiff(names(res), "symbol"))
      res <- res[, cols, drop = FALSE]
      return(res)
    }, error = function(e) {
      warning(paste0("Failed to fetch data for ticker: ", ticker), call. = FALSE)
      return(NULL)
    })
  })
  
  results <- results[!vapply(results, is.null, logical(1))]
  if (length(results) == 0) return(tibble::tibble())
  
  combined <- dplyr::bind_rows(results)
  return(tibble::as_tibble(combined))
}


#' Get Market Statistics
#'
#' @description
#' Retrieves key valuation and summary fields for given tickers.
#'
#' @param tickers Character vector of stock symbols.
#'
#' @return A `tibble` of market statistics with `symbol` as the first column.
#'
#' @examples
#' \donttest{
#' yf_get_market_stats("AAPL")
#' yf_get_market_stats(c("AAPL", "MSFT"))
#' }
#'
#' @export
yf_get_market_stats <- function(tickers) {
  results <- lapply(tickers, function(ticker) {
    tryCatch({
      obj <- Ticker$new(ticker)
      
      safe_extract <- function(x) if (is.null(x) || length(x) == 0) NA else x
      
      res <- data.frame(
        symbol = ticker,
        regular_market_price = safe_extract(obj$regular_market_price),
        fifty_two_week_high = safe_extract(obj$fifty_two_week_high),
        fifty_two_week_low = safe_extract(obj$fifty_two_week_low),
        regular_market_volume = safe_extract(obj$regular_market_volume),
        previous_close = safe_extract(obj$previous_close),
        currency = safe_extract(obj$currency),
        stringsAsFactors = FALSE
      )
      return(res)
    }, error = function(e) {
      warning(paste0("Failed to fetch data for ticker: ", ticker), call. = FALSE)
      return(NULL)
    })
  })
  
  results <- results[!vapply(results, is.null, logical(1))]
  if (length(results) == 0) return(tibble::tibble())
  
  combined <- dplyr::bind_rows(results)
  return(tibble::as_tibble(combined))
}


#' Get Financial Statements
#'
#' @description
#' Retrieves financial statements (income statement, balance sheet, or cash flow) for given tickers.
#'
#' @param tickers Character vector of stock symbols.
#' @param statement_type The type of financial statement to retrieve. One of "income", "balance-sheet", or "cash-flow".
#'
#' @return A `tibble` of financial data with `symbol` as the first column.
#'
#' @examples
#' \donttest{
#' yf_get_financials("AAPL", statement_type = "income")
#' }
#'
#' @export
yf_get_financials <- function(tickers, statement_type = c("income", "balance-sheet", "cash-flow")) {
  statement_type <- match.arg(statement_type)
  
  results <- lapply(tickers, function(ticker) {
    tryCatch({
      obj <- Ticker$new(ticker)
      
      res <- switch(statement_type,
        "income" = obj$get_income_statement(),
        "balance-sheet" = obj$get_balance_sheet(),
        "cash-flow" = obj$get_cash_flow()
      )
      
      if (is.null(res) || nrow(res) == 0) return(NULL)
      
      res$symbol <- ticker
      cols <- c("symbol", setdiff(names(res), "symbol"))
      res <- res[, cols, drop = FALSE]
      return(res)
    }, error = function(e) {
      warning(paste0("Failed to fetch data for ticker: ", ticker), call. = FALSE)
      return(NULL)
    })
  })
  
  results <- results[!vapply(results, is.null, logical(1))]
  if (length(results) == 0) return(tibble::tibble())
  
  combined <- dplyr::bind_rows(results)
  return(tibble::as_tibble(combined))
}


#' Get Index Quotes
#'
#' @description
#' Retrieves current quotes and summary statistics for a given index symbol.
#'
#' @param index_symbol Character string of the index symbol (e.g., "^GSPC").
#'
#' @return A `tibble` containing the index quote data.
#'
#' @examples
#' \donttest{
#' yf_get_index_quotes("^GSPC")
#' }
#'
#' @export
yf_get_index_quotes <- function(index_symbol) {
  tryCatch({
    obj <- Index$new(index_symbol)
    res <- obj$get_history(period = "1d", interval = "1d")
    
    if (is.null(res) || nrow(res) == 0) return(tibble::tibble())
    
    res$symbol <- index_symbol
    cols <- c("symbol", setdiff(names(res), "symbol"))
    res <- res[, cols, drop = FALSE]
    
    return(tibble::as_tibble(res))
  }, error = function(e) {
    warning(paste0("Failed to fetch data for index: ", index_symbol), call. = FALSE)
    return(tibble::tibble())
  })
}
