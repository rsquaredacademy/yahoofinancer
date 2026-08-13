test_that("yf_download_prices handles single and multi-ticker success", {
  MockTicker <- R6::R6Class("MockTicker",
    public = list(
      symbol = NULL,
      initialize = function(symbol) {
        if (symbol == "FAIL") stop("Simulated failure")
        self$symbol <- symbol
      },
      get_history = function(start = NULL, end = NULL, interval = "1d") {
        data.frame(date = as.POSIXct("2023-01-01"), close = 150)
      }
    )
  )
  
  testthat::local_mocked_bindings(Ticker = MockTicker, .package = "yahoofinancer")
  
  res <- yf_download_prices("AAPL")
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_equal(res$symbol, "AAPL")
  
  res2 <- yf_download_prices(c("AAPL", "MSFT"))
  expect_equal(nrow(res2), 2)
  expect_equal(res2$symbol, c("AAPL", "MSFT"))
  
  expect_warning(res3 <- yf_download_prices(c("AAPL", "FAIL")), "Failed to fetch data for ticker: FAIL")
  expect_equal(nrow(res3), 1)
  expect_equal(res3$symbol, "AAPL")
  
  expect_warning(res4 <- yf_download_prices("FAIL"), "Failed to fetch data for ticker: FAIL")
  expect_equal(nrow(res4), 0)
})

test_that("yf_get_market_stats works", {
  MockTicker <- R6::R6Class("MockTicker",
    public = list(
      symbol = NULL,
      regular_market_price = 150,
      fifty_two_week_high = 200,
      fifty_two_week_low = 100,
      regular_market_volume = 1000,
      previous_close = 145,
      currency = "USD",
      initialize = function(symbol) {
        if (symbol == "FAIL") stop("Simulated failure")
        self$symbol <- symbol
      }
    )
  )
  
  testthat::local_mocked_bindings(Ticker = MockTicker, .package = "yahoofinancer")
  
  res <- yf_get_market_stats("AAPL")
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_equal(res$symbol, "AAPL")
  expect_equal(res$regular_market_price, 150)
  
  res2 <- yf_get_market_stats(c("AAPL", "MSFT"))
  expect_equal(nrow(res2), 2)
  
  expect_warning(res3 <- yf_get_market_stats(c("AAPL", "FAIL")), "Failed to fetch data for ticker: FAIL")
  expect_equal(nrow(res3), 1)
})

test_that("yf_get_financials works", {
  MockTicker <- R6::R6Class("MockTicker",
    public = list(
      symbol = NULL,
      initialize = function(symbol) {
        if (symbol == "FAIL") stop("Simulated failure")
        self$symbol <- symbol
      },
      get_income_statement = function() {
        data.frame(date = "2023", revenue = 1000)
      },
      get_balance_sheet = function() {
        data.frame(date = "2023", assets = 5000)
      },
      get_cash_flow = function() {
        data.frame(date = "2023", fcf = 200)
      }
    )
  )
  
  testthat::local_mocked_bindings(Ticker = MockTicker, .package = "yahoofinancer")
  
  res <- yf_get_financials("AAPL", "income")
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_equal(res$revenue, 1000)
  
  res2 <- yf_get_financials("AAPL", "balance-sheet")
  expect_equal(res2$assets, 5000)
  
  res3 <- yf_get_financials(c("AAPL", "MSFT"), "cash-flow")
  expect_equal(nrow(res3), 2)
  expect_equal(res3$fcf, c(200, 200))
  
  expect_warning(res4 <- yf_get_financials(c("AAPL", "FAIL"), "income"), "Failed to fetch data for ticker: FAIL")
  expect_equal(nrow(res4), 1)
})

test_that("yf_get_index_quotes works", {
  MockIndex <- R6::R6Class("MockIndex",
    public = list(
      symbol = NULL,
      initialize = function(symbol) {
        if (symbol == "FAIL") stop("Simulated failure")
        self$symbol <- symbol
      },
      get_history = function(start = NULL, end = NULL, interval = "1d", period = "1d") {
        data.frame(date = as.POSIXct("2023-01-01"), close = 4000)
      }
    )
  )
  
  testthat::local_mocked_bindings(Index = MockIndex, .package = "yahoofinancer")
  
  res <- yf_get_index_quotes("^GSPC")
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 1)
  expect_equal(res$symbol, "^GSPC")
  
  expect_warning(res2 <- yf_get_index_quotes("FAIL"), "Failed to fetch data for index: FAIL")
  expect_equal(nrow(res2), 0)
})
