# H5: any request that is not mocked fails locally and never reaches the network.

test_that("an unmocked request is blocked by the suite-wide transport blocker", {
  skip_if(identical(Sys.getenv("YF_LIVE_TESTS"), "true"),
          "The offline blocker is disabled for explicitly opted-in live runs.")
  before <- .network_attempts$n
  expect_warning(
    out <- yahoofinancer:::api_request("https://query2.finance.yahoo.com/v8/finance/chart/AAPL"),
    "Network request failed: Unmocked network request blocked in tests"
  )
  expect_null(out)
  expect_equal(.network_attempts$n, before + 1L)
})

test_that("constructors with validation do not reach the network when validation is mocked", {
  before <- .network_attempts$n
  with_api(list(symbolsValidation = list(result = list(list(AAPL = TRUE)))), {
    expect_s3_class(Ticker$new("AAPL"), "Ticker")
  })
  expect_equal(.network_attempts$n, before)
})
