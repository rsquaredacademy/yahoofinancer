library(testthat)
library(yahoofinancer)
library(dplyr)

test_that("Tickers initializes and manages internal Ticker objects", {
  testthat::with_mocked_bindings(
    validate = function(x) TRUE,
    code = {
      symbols <- c("AAPL", "MSFT", "AAPL")
      tks <- Tickers$new(symbols)
      
      expect_equal(tks$symbols, c("AAPL", "MSFT"))
      expect_length(tks$ticker_objs, 2)
      expect_s3_class(tks$ticker_objs$AAPL, "Ticker")
    }
  )
})

test_that("aggregate_data handles various data shapes and mismatches", {
  testthat::with_mocked_bindings(
    validate = function(x) TRUE,
    code = {
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
    }
  )
})

test_that("Tickers is resilient to partial API failures", {
  testthat::with_mocked_bindings(
    validate = function(x) TRUE,
    code = {
      tks <- Tickers$new(c("GOOD", "FAIL"))
      
      mock_partial_fail <- function(t) {
        if (t$symbol == "FAIL") stop("Internal API Error")
        return(data.frame(val = 1))
      }
      
      res <- tks$aggregate_data(mock_partial_fail)
      expect_equal(nrow(res), 1)
      expect_equal(res$symbol, "GOOD")
    }
  )
})

test_that("Tickers is resilient to total API failure", {
  testthat::with_mocked_bindings(
    validate = function(x) TRUE,
    code = {
      tks <- Tickers$new(c("FAIL1", "FAIL2"))
      
      mock_total_fail <- function(t) stop("Total Failure")
      
      # The tryCatch inside aggregate_data should catch this
      res <- tks$aggregate_data(mock_total_fail)
      expect_null(res)
    }
  )
})

test_that("Tickers handle NULL or empty result from symbols", {
  testthat::with_mocked_bindings(
    validate = function(x) TRUE,
    code = {
      tks <- Tickers$new(c("EMPTY", "NULL"))
      
      mock_empty <- function(t) {
        if (t$symbol == "EMPTY") return(data.frame())
        return(NULL)
      }
      
      res <- tks$aggregate_data(mock_empty)
      expect_null(res)
    }
  )
})

test_that("Active bindings route correctly through aggregate_data", {
  testthat::with_mocked_bindings(
    validate = function(x) TRUE,
    code = {
      tks <- Tickers$new(c("AAPL", "MSFT"))
      
      # We need to mock the active bindings if they call API, 
      # but aggregate_data calls the function passed to it.
      # The active bindings in Tickers.R call self$aggregate_data(function(t) t$property)
      
      # For now, just call them to see if they work with our existing mocks
      with_mock_api(
        response_mock = mock_response(body_json = list(chart = list(result = list(list(meta = list(currency = "USD")))))),
        code = {
          expect_no_error(tks$currency)
          expect_no_error(tks$regular_market_price)
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
          expect_no_error(tks$get_history())
        }
      )
      
      with_mock_api(
        response_mock = mock_response(body_json = jsonlite::fromJSON("samples/rec_msft.json", simplifyVector = FALSE)),
        code = {
          expect_no_error(tks$recommendations)
        }
      )
      
      with_mock_api(
        response_mock = mock_response(body_json = jsonlite::fromJSON("samples/insights_2.json", simplifyVector = FALSE)),
        code = {
          expect_no_error(tks$technical_insights)
        }
      )

      with_mock_api(
        response_mock = mock_response(body_json = list(timeseries = list(result = list()))),
        code = {
          expect_no_error(tks$valuation_measures)
        }
      )
    }
  )
})
