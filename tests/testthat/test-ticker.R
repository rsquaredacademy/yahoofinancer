library(testthat)
library(yahoofinancer)

# Test User Story 1 - Ticker Offline Robustness (Priority: P1)

test_that("Ticker handles missing internet connection gracefully", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_message(aapl$get_history(), "No internet connection.")
      expect_null(aapl$get_history())
    }
  )
})

test_that("get_history issues warning on API failure", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(
      status_code = 404, 
      body_json = list(chart = list(error = list(description = "Symbol not found"))),
      is_error = TRUE
    ),
    code = {
      expect_warning(
        aapl$get_history(), 
        "Yahoo Finance API failed \\[404\\]: Symbol not found"
      )
    }
  )
})

test_that("get_history handles API failure with unknown error description", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(
      status_code = 500, 
      body_json = list(chart = list(error = list(something_else = "err"))),
      is_error = TRUE
    ),
    code = {
      expect_warning(
        aapl$get_history(), 
        "Yahoo Finance API failed \\[500\\]: Unknown Error"
      )
    }
  )
})

test_that("valuation_measures handles missing internet connection", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_message(aapl$valuation_measures, "No internet connection.")
      expect_null(aapl$valuation_measures)
    }
  )
})

test_that("valuation_measures handles API failure", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(status_code = 500, is_error = TRUE),
    code = {
      expect_warning(res <- aapl$valuation_measures, "Yahoo Finance API failed \\[500\\]: Unknown Error")
      expect_null(res)
    }
  )
})

test_that("valuation_measures handles empty result", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(body_json = list(timeseries = list(result = list()))),
    code = {
      expect_null(aapl$valuation_measures)
    }
  )
})

test_that("recommendations handles missing internet connection", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_null(aapl$recommendations)
    }
  )
})

test_that("recommendations handles API failure", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(status_code = 404, is_error = TRUE),
    code = {
      expect_warning(res <- aapl$recommendations, "Yahoo Finance API failed \\[404\\]: Unknown Error")
      expect_null(res)
    }
  )
})

test_that("technical_insights handles missing internet connection", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_null(aapl$technical_insights)
    }
  )
})

test_that("technical_insights handles API failure", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(status_code = 500, is_error = TRUE),
    code = {
      expect_warning(res <- aapl$technical_insights, "Yahoo Finance API failed \\[500\\]: Unknown Error")
      expect_null(res)
    }
  )
})

test_that("private meta_info handles missing internet connection", {
  aapl <- Ticker$new("AAPL")
  private_env <- aapl$.__enclos_env__$private
  
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_null(private_env$meta_info())
    }
  )
})

test_that("private meta_info handles API failure", {
  aapl <- Ticker$new("AAPL")
  private_env <- aapl$.__enclos_env__$private
  
  with_mock_api(
    response_mock = mock_response(status_code = 404, is_error = TRUE),
    code = {
      expect_warning(res <- private_env$meta_info(), "Yahoo Finance API failed \\[404\\]: Unknown Error")
      expect_null(res)
    }
  )
})

test_that("get_history handles invalid date strings", {
  aapl <- Ticker$new("AAPL")
  expect_error(aapl$get_history(start = "invalid"), "Invalid 'start' date format")
  expect_error(aapl$get_history(end = "invalid"), "Invalid 'end' date format")
})


