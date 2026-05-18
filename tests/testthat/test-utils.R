library(testthat)
library(yahoofinancer)

test_that("validate handles missing internet connection", {
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_message(validate("AAPL"), "No internet connection.")
      expect_null(validate("AAPL"))
    }
  )
})

test_that("validate handles API failure", {
  with_mock_api(
    response_mock = mock_response(
      status_code = 500,
      body_json = list(quoteSummary = list(error = list(code = "ERR", description = "Error"))),
      is_error = TRUE
    ),
    code = {
      expect_output(validate("AAPL"), "Yahoo Finance API request failed")
      expect_null(validate("AAPL"))
    }
  )
})

test_that("flatten_list handles edge cases", {
  # NULL input
  expect_null(flatten_list(NULL))
  
  # Empty list
  expect_null(flatten_list(list()))
  
  # List with NULLs
  expect_equal(flatten_list(list(1, NULL, 3)), c(1, NA, 3))
  
  # List with all NULLs
  expect_equal(flatten_list(list(NULL, NULL)), as.logical(c(NA, NA)))
})
