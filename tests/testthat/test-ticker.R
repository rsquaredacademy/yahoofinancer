library(testthat)
library(httptest)

# Ensure we use the mock directory
.mockPaths("samples")

with_mock_api({
  # Mocking the validation to stay network-independent
  testthat::with_mocked_bindings(
    validate = function(symbol) return(TRUE),
    code = {
      
      # Test 1: Initialization and Basic Properties
      test_that("Ticker initializes and handles basic properties", {
        aapl <- Ticker$new("AAPL")
        expect_s3_class(aapl, "Ticker")
        expect_equal(aapl$symbol, "AAPL")
        
        # Test an active binding (ensure mock exists in samples/)
        # Using expect_no_error to ensure the API parsing logic is sound
        expect_no_error(aapl$regular_market_price)
      })

      # Test 2: get_history with 'period' (Branch A)
      test_that("get_history handles 'period' correctly", {
        aapl <- Ticker$new("AAPL")
        hist <- aapl$get_history(period = "1mo", interval = "1d")
        
        expect_s3_class(hist, "data.frame")
        expect_true(all(c("date", "open", "high", "low", "close", "volume") %in% names(hist)))
      })

      # Test 3: get_history with 'start' and 'end' (Branch B)
      test_that("get_history handles specific dates correctly", {
        aapl <- Ticker$new("AAPL")
        # Passing strings - ensure your logic converts these to Unix timestamps
        hist <- aapl$get_history(start = "2023-01-01", end = "2023-01-10")
        
        expect_s3_class(hist, "data.frame")
      })

      # Test 4: Input Validation (CRAN Requirement: Graceful Failure)
      test_that("Ticker throws helpful errors for invalid inputs", {
        aapl <- Ticker$new("AAPL")
        
        # Test invalid interval
        expect_error(aapl$get_history(interval = "3.5days"))
        
        # Test invalid period
        expect_error(aapl$get_history(period = "forever"))
        
        # Test start date in wrong format (if your code handles this)
        expect_error(aapl$get_history(start = "not-a-date"))
      })

    }
  )
})

if (requireNamespace("httptest", quietly = TRUE)) {
  httptest::with_mock_api({
    test_that("output from get history is as expected", {
      testthat::skip_on_cran()
      aapl <- Ticker$new('aapl')
      trend <- aapl$get_history(start = '2022-09-01',
                                end = '2022-09-05',
                                interval = '1d')

      expect_equal(nrow(trend), 2)
      expect_equal(as.Date(trend$date), as.Date(c("2022-09-01", "2022-09-02")))
      expect_equal(round(trend$high, 2), c(158.42, 160.36))
      expect_equal(round(trend$low, 2), c(154.67, 154.97))
      expect_equal(round(trend$open, 2), c(156.64, 159.75))
      expect_equal(round(trend$close, 2), c(157.96, 155.81))

    })
  })
}

test_that("symbols are properly validated", {
  testthat::skip_on_cran()
  aapl <- Ticker$new("aapl")
  expect_error(Ticker$new("aapls"), "Not a valid symbol.")
  expect_error(aapl$set_symbol("aapls"), "Not a valid symbol.")
})

test_that("Ticker initialization handles invalid symbols", {
  # If 'validate' is mocked globally to return TRUE, 
  # we must override it here to return FALSE
  testthat::with_mocked_bindings(
    validate = function(symbol) {
      if (is.na(symbol) || is.null(symbol) || symbol == "") return(FALSE)
      return(TRUE)
    },
    code = {
      expect_error(Ticker$new(NA), "Not a valid symbol.")
      expect_error(Ticker$new(NULL), "Not a valid symbol.")
      expect_error(Ticker$new(""), "Not a valid symbol.")
    }
  )
})

test_that("set_symbol handles invalid symbols", {
  aapl <- Ticker$new("AAPL")
  
  # Trigger the 'else' block in set_symbol (Lines 46-47)
  testthat::with_mocked_bindings(
    validate = function(symbol) FALSE,
    code = {
      expect_error(aapl$set_symbol("INVALID"), "Not a valid symbol.")
    }
  )
})

test_that("get_history catches invalid end date formats", {
  aapl <- Ticker$new("AAPL")
  
  expect_error(
    aapl$get_history(end = "invalid-date-format"), 
    "Invalid 'end' date format. Please use 'YYYY-MM-DD'."
  )
})

test_that("get_history handles start date only (defaults end to current time)", {
  aapl <- Ticker$new("AAPL")
  
  res <- aapl$get_history(start = "2024-01-01")
  
  expect_s3_class(res, "data.frame")
  expect_true(nrow(res) > 0)
})

test_that("get_history issues warning on API failure", {
  aapl <- Ticker$new("AAPL")
  
  # Mocking GET and content to simulate a 404 error with a JSON body
  testthat::with_mocked_bindings(
    GET = function(...) {
      list(status_code = 404)
    },
    content = function(...) {
      '{"chart":{"error":{"description":"Symbol not found"}}}'
    },
    http_error = function(...) TRUE,
    status_code = function(...) 404,
    .package = "httr", # Note the dot before package
    code = {
      # This triggers the if (httr::http_error(resp)) block (Lines 98-102)
      expect_warning(
        aapl$get_history(), 
        "Yahoo Finance API failed \\[404\\]: Symbol not found"
      )
    }
  )
})

test_that("get_history returns empty data frame when timestamp is missing", {
  aapl <- Ticker$new("AAPL")
  
  # We mock the internal calls to return a structure where timestamp is NULL
  testthat::with_mocked_bindings(
    GET = function(...) list(status_code = 200),
    content = function(...) {
      # This JSON has the result list, but timestamp is null
      '{"chart":{"result":[{"indicators":{"quote":[{}]},"timestamp":null}]}}'
    },
    http_error = function(...) FALSE,
    .package = "httr",
    code = {
      res <- aapl$get_history()
      
      expect_s3_class(res, "data.frame")
      expect_equal(nrow(res), 0)
    }
  )
})

test_that("set_symbol updates the symbol correctly", {
  aapl <- Ticker$new("AAPL")
  aapl$set_symbol("MSFT")
  expect_equal(aapl$symbol, "MSFT")
})

test_that("get_history handles missing internet connection", {
  aapl <- Ticker$new("AAPL")
  
  # Mocking curl::has_internet to return FALSE
  testthat::with_mocked_bindings(
    has_internet = function() FALSE,
    .package = "curl",
    code = {
      expect_message(aapl$get_history(), "No internet connection.")
      expect_null(aapl$get_history())
    }
  )
})

test_that("ticker.R: Private extract_valuation handles NULL/Empty", {
  aapl <- Ticker$new("AAPL")
  
  # We access the private method directly through the R6 object's internal environment
  private_env <- aapl$.__enclos_env__$private
  
  expect_equal(length(private_env$extract_valuation(NULL, "pe")), 0)
  expect_equal(length(private_env$extract_valuation(list(), "pe")), 0)
})
