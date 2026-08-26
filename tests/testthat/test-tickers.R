library(testthat)
library(yahoofinancer)
library(dplyr)

test_that("Tickers initializes and manages internal Ticker objects", {
  testthat::with_mocked_bindings(
    validate = function(x, ...) TRUE,
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
    validate = function(x, ...) TRUE,
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

test_that("Tickers is resilient to partial API failures and emits warning", {
  testthat::with_mocked_bindings(
    validate = function(x, ...) TRUE,
    code = {
      tks <- Tickers$new(c("GOOD", "FAIL"))

      mock_partial_fail <- function(t) {
        if (t$symbol == "FAIL") stop("Internal API Error")
        return(data.frame(val = 1))
      }

      expect_warning(res <- tks$aggregate_data(mock_partial_fail), "Failed to fetch data for ticker: FAIL")
      expect_equal(nrow(res), 1)
      expect_equal(res$symbol, "GOOD")
    }
  )
})

test_that("Tickers is resilient to total API failure and emits warnings", {
  testthat::with_mocked_bindings(
    validate = function(x, ...) TRUE,
    code = {
      tks <- Tickers$new(c("FAIL1", "FAIL2"))

      mock_total_fail <- function(t) stop("Total Failure")

      expect_warning(
        expect_warning(res <- tks$aggregate_data(mock_total_fail), "Failed to fetch data for ticker: FAIL1"),
        "Failed to fetch data for ticker: FAIL2"
      )
      expect_null(res)
    }
  )
})

test_that("Tickers handle NULL or empty result from symbols", {
  testthat::with_mocked_bindings(
    validate = function(x, ...) TRUE,
    code = {
      tks <- Tickers$new(c("EMPTY", "NULL"))

      mock_empty <- function(t) {
        if (t$symbol == "EMPTY") return(data.frame())
        return(NULL)
      }

      expect_warning(
        expect_warning(res <- tks$aggregate_data(mock_empty), "Failed to fetch data for ticker: EMPTY"),
        "Failed to fetch data for ticker: NULL"
      )
      expect_null(res)
    }
  )
})

test_that("Active bindings route correctly through aggregate_data", {
  testthat::with_mocked_bindings(
    validate = function(x, ...) TRUE,
    code = {
      tks <- Tickers$new(c("AAPL", "MSFT"))

      with_mock_api(
        response_mock = mock_response(body_json = list(chart = list(result = list(list(meta = list(currency = "USD", regularMarketPrice = 150.0)))))),
        code = {
          res <- tks$currency
          expect_s3_class(res, "data.frame")
          expect_true("symbol" %in% names(res))
          expect_true("value" %in% names(res))
          expect_equal(nrow(res), 2)

          res_rmp <- tks$regular_market_price
          expect_s3_class(res_rmp, "data.frame")
          expect_true("value" %in% names(res_rmp))
        }
      )

      with_mock_api(
        response_mock = mock_response(body_json = jsonlite::fromJSON("samples/rec_msft.json", simplifyVector = FALSE)),
        code = {
          res <- tks$recommendations
          expect_s3_class(res, "data.frame")
          expect_true("symbol" %in% names(res))
          expect_true("recommended_symbol" %in% names(res))
        }
      )

      with_mock_api(
        response_mock = mock_response(body_json = jsonlite::fromJSON("samples/insights_2.json", simplifyVector = FALSE)),
        code = {
          res <- tks$technical_insights
          expect_s3_class(res, "data.frame")
          expect_true("symbol" %in% names(res))
        }
      )

      with_mock_api(
        response_mock = mock_response(body_json = list(timeseries = list(result = list()))),
        code = {
          expect_warning(
            expect_warning(res <- tks$valuation_measures, "Failed to fetch data for ticker: AAPL"),
            "Failed to fetch data for ticker: MSFT"
          )
          expect_null(res)
        }
      )
    }
  )
})
