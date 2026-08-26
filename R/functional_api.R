#' Download Historical Prices
#'
#' @description
#' Fetches historical OHLCV price data for one or more tickers using the
#' Yahoo Finance chart API. Results are combined into a single long-format
#' tibble suitable for \code{dplyr} pipelines.
#'
#' **Intraday lookback limits** (imposed by Yahoo Finance):
#' \itemize{
#'   \item \code{"1m"}: max 7 days
#'   \item \code{"5m"}, \code{"15m"}, \code{"30m"}: max 60 days
#'   \item \code{"1h"}: max 730 days
#' }
#'
#' @param tickers Character vector of one or more stock symbols
#'   (e.g., \code{c("AAPL", "MSFT")}).
#' @param start Date or character string in \code{"YYYY-MM-DD"} format
#'   representing the start date. When provided, \code{period} is ignored.
#' @param end Date or character string in \code{"YYYY-MM-DD"} format
#'   representing the end date. Defaults to today if \code{start} is set
#'   but \code{end} is \code{NULL}.
#' @param interval Time between data points. Valid values:
#'   \code{"1m"}, \code{"2m"}, \code{"5m"}, \code{"15m"}, \code{"30m"},
#'   \code{"60m"}, \code{"90m"}, \code{"1h"}, \code{"1d"}, \code{"5d"},
#'   \code{"1wk"}, \code{"1mo"}, \code{"3mo"}. Defaults to \code{"1d"}.
#' @param period Relative time period. Valid values:
#'   \code{"1d"}, \code{"5d"}, \code{"1mo"}, \code{"3mo"}, \code{"6mo"},
#'   \code{"1y"}, \code{"2y"}, \code{"5y"}, \code{"10y"}, \code{"ytd"},
#'   \code{"max"}. Defaults to \code{"1y"} when both \code{start} and
#'   \code{period} are \code{NULL}.
#'
#' @return A \code{\link[tibble]{tibble}} with 8 columns:
#'   \code{symbol}, \code{date}, \code{open}, \code{high}, \code{low},
#'   \code{close}, \code{adj_close}, \code{volume}.
#'   Returns an empty tibble if all tickers fail.
#'
#' @family historical data
#'
#' @examples
#' \dontrun{
#' # Single ticker with date range
#' yf_download_prices("AAPL", start = "2023-01-01", end = "2023-01-10")
#'
#' # Multiple tickers with relative period
#' yf_download_prices(c("AAPL", "MSFT"), period = "6mo", interval = "1mo")
#' }
#'
#' @export
yf_download_prices <- function(tickers, start = NULL, end = NULL, interval = "1d", period = NULL) {

  if (!is.null(start) && !is.null(period)) {
    warning("Both 'start' and 'period' were provided. Using explicit 'start' and 'end' dates and ignoring 'period'.", call. = FALSE)
    period <- NULL
  }

  if (is.null(start) && is.null(period)) {
    period <- "1y"
  }

  if (!is.null(period)) {
    valid_periods <- c("1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max")
    if (!(period %in% valid_periods)) {
      stop(paste0("Invalid period: '", period, "'. Valid periods are: ", paste(valid_periods, collapse = ", ")), call. = FALSE)
    }
  }

  results <- lapply(tickers, function(ticker) {
    tryCatch({
      obj <- Ticker$new(ticker)
      res <- obj$get_history(start = start, end = end, interval = interval, period = period)
      if (is.null(res) || nrow(res) == 0) {
        warning(paste0("Failed to fetch data for ticker: ", ticker), call. = FALSE)
        return(NULL)
      }

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
#' Retrieves key real-time valuation and summary fields for one or more
#' tickers.
#'
#' @param tickers Character vector of stock symbols.
#'
#' @return A \code{\link[tibble]{tibble}} with 7 columns:
#'   \code{symbol} (character), \code{regular_market_price} (numeric),
#'   \code{fifty_two_week_high} (numeric), \code{fifty_two_week_low} (numeric),
#'   \code{regular_market_volume} (numeric), \code{previous_close} (numeric),
#'   \code{currency} (character).
#'   Returns an empty tibble if all tickers fail.
#'
#' @family market data
#'
#' @examples
#' \dontrun{
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
#' Retrieves quarterly or annual financial statements (income statement,
#' balance sheet, or cash flow) for one or more tickers.
#'
#' @param tickers Character vector of stock symbols.
#' @param statement_type The type of financial statement to retrieve.
#'   One of \code{"income"}, \code{"balance-sheet"}, or \code{"cash-flow"}.
#' @param frequency One of \code{"annual"} or \code{"quarterly"}. Defaults to \code{"annual"}.
#'
#' @return A \code{\link[tibble]{tibble}} with \code{symbol} as the first
#'   column. Remaining columns vary by \code{statement_type} and reflect the
#'   line items returned by the Yahoo Finance API.
#'   Returns an empty tibble if all tickers fail.
#'
#' @family fundamental data
#'
#' @examples
#' \dontrun{
#' yf_get_financials("AAPL", statement_type = "income")
#' yf_get_financials(c("AAPL", "MSFT"), statement_type = "balance-sheet", frequency = "quarterly")
#' }
#'
#' @export
yf_get_financials <- function(tickers, statement_type = c("income", "balance-sheet", "cash-flow"), frequency = c("annual", "quarterly")) {
  statement_type <- match.arg(statement_type)
  frequency <- match.arg(frequency)

  results <- lapply(tickers, function(ticker) {
    tryCatch({
      obj <- Ticker$new(ticker)

      res <- switch(statement_type,
        "income" = obj$get_income_statement(frequency = frequency),
        "balance-sheet" = obj$get_balance_sheet(frequency = frequency),
        "cash-flow" = obj$get_cash_flow(frequency = frequency)
      )

      if (is.null(res) || nrow(res) == 0) {
        warning(paste0("Failed to fetch data for ticker: ", ticker), call. = FALSE)
        return(NULL)
      }

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
#' Retrieves the most recent 1-day price snapshot for a given market index.
#'
#' @param index_symbol Character string of the index symbol (e.g.,
#'   \code{"^GSPC"} for S&P 500, \code{"^NSEI"} for Nifty 50).
#'
#' @return A \code{\link[tibble]{tibble}} with the same 8-column schema as
#'   \code{\link{yf_download_prices}}: \code{symbol}, \code{date},
#'   \code{open}, \code{high}, \code{low}, \code{close}, \code{adj_close},
#'   \code{volume}.
#'   Returns an empty tibble on failure.
#'
#' @family historical data
#'
#' @examples
#' \dontrun{
#' yf_get_index_quotes("^GSPC")
#' }
#'
#' @export
yf_get_index_quotes <- function(index_symbol) {
  tryCatch({
    obj <- Index$new(index_symbol)
    res <- obj$get_history(period = "1d", interval = "1d")

    if (is.null(res) || nrow(res) == 0) {
      warning(paste0("Failed to fetch data for index: ", index_symbol), call. = FALSE)
      return(tibble::tibble())
    }

    return(res)
  }, error = function(e) {
    warning(paste0("Failed to fetch data for index: ", index_symbol), call. = FALSE)
    return(tibble::tibble())
  })
}
