#' Multi-Symbol Ticker Data Aggregator
#'
#' @description
#' An R6 class to manage and aggregate data from multiple Yahoo Finance tickers
#' simultaneously. It wraps the \code{Ticker} class to provide a unified,
#' long-format data interface suitable for bulk analysis and visualization.
#'
#' @details
#' The \code{Tickers} class automates the process of iterating over a vector of
#' symbols. It handles per-symbol errors gracefully via an internal
#' \code{aggregate_data} helper, ensuring that a failure in one symbol does
#' not prevent the collection of data for others.
#'
#' Most properties return a \code{data.frame} where the first column is
#' \code{symbol}, facilitating easy filtering and joining in tidy workflows.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Initialize for a set of tech stocks
#' stocks <- Tickers$new(c("AAPL", "MSFT", "GOOGL"))
#'
#' # 1. Get 1 month of historical daily prices
#' hist_data <- stocks$get_history(period = "1mo", interval = "1d")
#' head(hist_data)
#'
#' # 2. Get current market prices for the group
#' current_prices <- stocks$regular_market_price
#'
#' # 3. View recommended related symbols and scores
#' recs <- stocks$recommendations
#'
#' # 4. Get technical insights (RSI, Moving Averages)
#' tech <- stocks$technical_insights
#' }
#'
#' @importFrom dplyr bind_rows
#'
Tickers <- R6::R6Class("Tickers",
  public = list(
    #' @field symbols A unique character vector of symbols being tracked.
    symbols = NULL,

    #' @field ticker_objs A named list of underlying \code{Ticker} R6 objects.
    ticker_objs = NULL,

    #' @description
    #' Create a new Tickers object.
    #' @param symbols A character vector of Yahoo Finance ticker symbols.
    #' @return A new \code{Tickers} object.
    initialize = function(symbols) {
      self$symbols <- unique(symbols)
      self$ticker_objs <- lapply(self$symbols, Ticker$new)
      names(self$ticker_objs) <- self$symbols
    },

    #' @description
    #' Retrieve historical market data for all symbols.
    #' @param period The duration of history to fetch; "1d", "5d", "1mo", "1y", "max" etc.
    #' @param interval The frequency of data points; "1m", "2m", "5m", "1h", "1d", "1wk" etc.
    #' @param start Date or timestamp for the start of the period.
    #' @param end Date or timestamp for the end of the period.
    #' @return A tidy \code{data.frame} containing historical prices and volumes.
    get_history = function(period = "1y", interval = "1d", start = NULL, end = NULL) {
      self$aggregate_data(function(t) t$get_history(period, interval, start, end))
    },

    #' @description
    #' Internal helper to execute a method across all symbols and combine results.
    #' @param fn A function or anonymous function that takes a \code{Ticker} object.
    #' @return A combined \code{data.frame} or \code{NULL}.
    aggregate_data = function(fn) {
      results <- lapply(self$ticker_objs, function(t) {
        tryCatch({
          data <- fn(t)
          if (is.null(data) || length(data) == 0) return(NULL)

          if (is.data.frame(data)) {
            # Handle recommendation column collision
            if ("symbol" %in% names(data) && !"date" %in% names(data)) {
              names(data)[names(data) == "symbol"] <- "recommended_symbol"
            }

            data$symbol <- t$symbol
            # Move symbol to the first column
            cols <- c("symbol", setdiff(names(data), "symbol"))
            return(data[, cols, drop = FALSE])
          }

          # Return a simple data frame for single values
          return(data.frame(
            symbol = t$symbol,
            value = data,
            stringsAsFactors = FALSE
          ))
        }, error = function(e) return(NULL))
      })

      # Filter out NULLs (failed API calls or errors)
      results <- results[!vapply(results, is.null, logical(1))]

      if (length(results) == 0) return(NULL)

      # Use dplyr to safely bind rows even if columns mismatch
      combined <- dplyr::bind_rows(results)

      # Clean up row names (dplyr usually handles this, but good for safety)
      row.names(combined) <- NULL

      return(combined)
    }
  ),

  active = list(
    #' @field recommendations Related symbols suggested by Yahoo Finance and their relevance scores.
    recommendations         = function() self$aggregate_data(function(t) t$recommendations),

    #' @field valuation_measures Quarterly valuation statistics including PE and Enterprise Value.
    valuation_measures      = function() self$aggregate_data(function(t) t$valuation_measures),

    #' @field technical_insights Technical indicator snapshots (e.g., RSI, Moving Averages).
    technical_insights      = function() self$aggregate_data(function(t) t$technical_insights),

    #' @field regular_market_price The current market price for each symbol.
    regular_market_price    = function() self$aggregate_data(function(t) t$regular_market_price),

    #' @field regular_market_time The timestamp of the last market trade.
    regular_market_time     = function() self$aggregate_data(function(t) t$regular_market_time),

    #' @field regular_market_volume The current trading volume.
    regular_market_volume   = function() self$aggregate_data(function(t) t$regular_market_volume),

    #' @field regular_market_day_high The highest price during the current trading session.
    regular_market_day_high = function() self$aggregate_data(function(t) t$regular_market_day_high),

    #' @field regular_market_day_low The lowest price during the current trading session.
    regular_market_day_low  = function() self$aggregate_data(function(t) t$regular_market_day_low),

    #' @field previous_close The closing price of the previous trading day.
    previous_close          = function() self$aggregate_data(function(t) t$previous_close),

    #' @field fifty_two_week_high The highest price over the last 52 weeks.
    fifty_two_week_high     = function() self$aggregate_data(function(t) t$fifty_two_week_high),

    #' @field fifty_two_week_low The lowest price over the last 52 weeks.
    fifty_two_week_low      = function() self$aggregate_data(function(t) t$fifty_two_week_low),

    #' @field currency The currency code (e.g., "USD") for the symbols.
    currency                = function() self$aggregate_data(function(t) t$currency),

    #' @field exchange_name The short name of the stock exchange.
    exchange_name           = function() self$aggregate_data(function(t) t$exchange_name),

    #' @field full_exchange_name The full name of the stock exchange.
    full_exchange_name      = function() self$aggregate_data(function(t) t$full_exchange_name),

    #' @field first_trade_date The Unix timestamp of the first recorded trade.
    first_trade_date        = function() self$aggregate_data(function(t) t$first_trade_date),

    #' @field timezone The timezone code (e.g., "EDT").
    timezone                = function() self$aggregate_data(function(t) t$timezone),

    #' @field exchange_timezone_name The full name of the exchange's timezone.
    exchange_timezone_name  = function() self$aggregate_data(function(t) t$exchange_timezone_name)
  )
)
