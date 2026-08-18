test_that("yf_download_prices handles single and multi-ticker success", {
  MockTicker <- R6::R6Class("MockTicker",
    public = list(
      symbol = NULL,
      initialize = function(symbol) {
        if (symbol == "FAIL") stop("Simulated failure")
        self$symbol <- symbol
      },
      get_history = function(start = NULL, end = NULL, interval = "1d", period = NULL) {
        tibble::tibble(symbol = self$symbol, date = as.POSIXct("2023-01-01"), open = 150, high = 150, low = 150, close = 150, adj_close = 150, volume = 1000)
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

test_that("yf_download_prices supports period argument and precedence rules", {
  MockTicker <- R6::R6Class("MockTicker",
    public = list(
      symbol = NULL,
      initialize = function(symbol) {
        self$symbol <- symbol
      },
      get_history = function(start = NULL, end = NULL, interval = "1d", period = NULL) {
        tibble::tibble(
          symbol = self$symbol,
          date = as.POSIXct("2023-01-01"), 
          open = 150, high = 150, low = 150, close = 150, adj_close = 150, volume = 1000,
          captured_start = if (is.null(start)) NA_character_ else as.character(start),
          captured_period = if (is.null(period)) NA_character_ else period
        )
      }
    )
  )
  
  testthat::local_mocked_bindings(Ticker = MockTicker, .package = "yahoofinancer")
  
  # 1 & 2. Valid periods
  res_6mo <- yf_download_prices("AAPL", period = "6mo")
  expect_equal(res_6mo$captured_period, "6mo")
  expect_true(is.na(res_6mo$captured_start))
  
  res_1mo <- yf_download_prices("AAPL", period = "1mo")
  expect_equal(res_1mo$captured_period, "1mo")
  
  res_ytd <- yf_download_prices("AAPL", period = "ytd")
  expect_equal(res_ytd$captured_period, "ytd")
  
  # 3. Invalid period
  expect_error(yf_download_prices("AAPL", period = "100years"), "Invalid period: '100years'")
  
  # 4. Both start and period provided (warns and ignores period)
  expect_warning(
    res_both <- yf_download_prices("AAPL", start = "2023-01-01", period = "6mo"),
    "Both 'start' and 'period' were provided"
  )
  expect_equal(res_both$captured_start, "2023-01-01")
  expect_true(is.na(res_both$captured_period))
  
  # 5. Default behavior (start=NULL, period=NULL)
  res_default <- yf_download_prices("AAPL")
  expect_equal(res_default$captured_period, "1y")
  expect_true(is.na(res_default$captured_start))
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
        tibble::tibble(symbol = self$symbol, date = as.POSIXct("2023-01-01"), open = 4000, high = 4000, low = 4000, close = 4000, adj_close = 4000, volume = 1000)
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
