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
})

test_that("get_metric handles edge cases", {
  data <- list(
    volume = list(100, NULL, 300),
    price = list(10.5, 11.0)
  )
  
  # Normal usage
  expect_equal(get_metric(data, "volume"), c(100, NA, 300))
  
  # Missing metric
  expect_null(get_metric(data, "invalid"))
  
  # NULL data
  expect_null(get_metric(NULL, "volume"))
})

