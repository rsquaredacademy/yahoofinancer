library(testthat)
library(httptest)
library(dplyr)

.mockPaths("samples")

with_mock_api({
  testthat::with_mocked_bindings(
    validate = function(symbol) return(TRUE),
    code = {
      # --- 1. Initialization ---
      test_that("Tickers initializes and manages internal Ticker objects", {
        symbols <- c("AAPL", "MSFT", "AAPL")
        tks <- Tickers$new(symbols)
        
        expect_equal(tks$symbols, c("AAPL", "MSFT"))
        expect_length(tks$ticker_objs, 2)
        expect_s3_class(tks$ticker_objs$AAPL, "Ticker")
      })

      # --- 2. Aggregate Data Logic ---
      test_that("aggregate_data handles various data shapes and mismatches", {
        tks <- Tickers$new(c("AAPL", "MSFT"))
        
        # Test Path: Column Mismatch
        mock_mismatch <- function(t) {
          if (t$symbol == "AAPL") {
            return(data.frame(price = 150, unique_col = "special"))
          } else {
            return(data.frame(price = 160))
          }
        }
        res_mismatch <- tks$aggregate_data(mock_mismatch)
        expect_true("unique_col" %in% names(res_mismatch))
        expect_true(is.na(res_mismatch$unique_col[res_mismatch$symbol == "MSFT"]))

        # Test Path: Recommendation Renaming
        mock_rec <- function(t) data.frame(symbol = "GOOG", score = 0.5)
        res_rec <- tks$aggregate_data(mock_rec)
        expect_named(res_rec, c("symbol", "recommended_symbol", "score"))
      })

      # --- 3. Historical Data ---
      test_that("get_history aggregates time-series data correctly", {
        tks <- Tickers$new(c("AAPL", "MSFT"))
        
        mock_hist <- function(t) {
          data.frame(
            date = as.POSIXct(c("2026-04-01", "2026-04-02"), tz = "UTC"),
            close = c(100, 105),
            symbol = t$symbol
          )
        }
        
        res <- tks$aggregate_data(mock_hist)
        expect_equal(nrow(res), 4)
        expect_equal(names(res)[1], "symbol")
      })

      # --- 4. Active Bindings Coverage ---
      test_that("Active bindings route correctly through aggregate_data", {
        tks <- Tickers$new(c("AAPL", "MSFT"))
        
        # Check that common bindings don't crash
        expect_no_error(tks$regular_market_price)
        expect_no_error(tks$currency)
        expect_no_error(tks$recommendations)
        expect_no_error(tks$valuation_measures)
        expect_no_error(tks$technical_insights)
        expect_no_error(tks$regular_market_time)
        expect_no_error(tks$regular_market_volume)
        expect_no_error(tks$regular_market_day_high)
        expect_no_error(tks$regular_market_day_low)
        expect_no_error(tks$previous_close)
        expect_no_error(tks$fifty_two_week_high)
        expect_no_error(tks$fifty_two_week_low)
        expect_no_error(tks$exchange_name)
        expect_no_error(tks$full_exchange_name)
        expect_no_error(tks$first_trade_date)
        expect_no_error(tks$timezone)
        expect_no_error(tks$exchange_timezone_name)
      })

      # --- 5. Error Handling & Resilience ---
      test_that("Tickers is resilient to partial API failures", {
        tks <- Tickers$new(c("GOOD", "FAIL"))
        
        mock_partial_fail <- function(t) {
          if (t$symbol == "FAIL") stop("Internal API Error")
          return(data.frame(val = 1))
        }
        
        res <- tks$aggregate_data(mock_partial_fail)
        expect_equal(nrow(res), 1)
        expect_equal(res$symbol, "GOOD")
      })
    }
  )
})
