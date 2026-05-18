library(testthat)
library(yahoofinancer)

test_that("Index handles missing internet connection gracefully", {
  nifty <- Index$new("^NSEI")
  
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_message(nifty$get_history(), "No internet connection.")
      expect_null(nifty$get_history())
    }
  )
})

test_that("Index$get_history handles API failure", {
  nifty <- Index$new("^NSEI")
  
  with_mock_api(
    response_mock = mock_response(
      status_code = 404,
      body_json = list(chart = list(error = list(description = "Symbol not found"))),
      is_error = TRUE
    ),
    code = {
      expect_warning(res <- nifty$get_history(), "Yahoo Finance API failed \\[404\\]: Symbol not found")
      expect_null(res)
    }
  )
})

test_that("Index initialization and set_index handle invalid symbol", {
  test_idx <- "^NSEI"
  nse <- Index$new(symbol = test_idx)
  expect_equal(nse$symbol, test_idx)
  expect_warning(expect_equal(nse$index, test_idx), "The 'index' field is deprecated")
  
  testthat::with_mocked_bindings(
    validate = function(x) FALSE,
    code = {
      expect_error(Index$new("INVALID"), "Not a valid symbol.")
      expect_error(nse$set_index("INVALID"), "Not a valid symbol.")
    }
  )
})

test_that("Index supports deprecation of index parameter", {
  # Warning on initialize with index
  expect_warning(Index$new(index = "^NSEI"), "The 'index' parameter is deprecated")
  
  # Warning on set_index with index
  nifty <- Index$new("^NSEI")
  expect_warning(nifty$set_index(index = "^NDX"), "The 'index' parameter is deprecated")
  expect_equal(nifty$symbol, "^NDX")
  
  # Warning on index setter
  expect_warning(nifty$index <- "^NSEI", "The 'index' field is deprecated")
  expect_equal(nifty$symbol, "^NSEI")
})

test_that("get_history handles invalid date strings", {
  nifty <- Index$new("^NSEI")
  expect_error(nifty$get_history(start = "invalid"), "Invalid 'start' date format")
  expect_error(nifty$get_history(end = "invalid"), "Invalid 'end' date format")
})
