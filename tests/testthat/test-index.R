library(testthat)
library(yahoofinancer)

# Test User Story 2 - Indice and Utility Edge Cases (Priority: P1)

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

test_that("Index$get_history handles API failure with message", {
  nifty <- Index$new("^NSEI")
  
  # Index.R uses message() + cat() for errors
  with_mock_api(
    response_mock = mock_response(
      status_code = 404,
      body_json = list(quoteSummary = list(error = list(code = "NOT_FOUND", description = "Symbol not found"))),
      is_error = TRUE
    ),
    code = {
      # Use expect_output because it uses message(cat(...))
      expect_output(nifty$get_history(), "Yahoo Finance API request failed")
      expect_null(nifty$get_history())
    }
  )
})

test_that("Index initialization and set_index handle invalid index", {
  # maintains self$index
  test_idx <- "^NSEI"
  nse <- Index$new(test_idx)
  expect_equal(nse$index, test_idx)
  
  testthat::with_mocked_bindings(
    validate = function(x) FALSE,
    code = {
      expect_message(Index$new("INVALID"), "Not a valid index.")
      expect_message(nse$set_index("INVALID"), "Not a valid index.")
    }
  )
})


