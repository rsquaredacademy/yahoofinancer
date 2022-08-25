httptest::with_mock_api({
  test_that("output from market summary is as expected", {
    testthat::skip_on_cran()
    trend <- get_market_summary()
    expect_equal(length(trend[[1]]), 29)
    expect_equal(trend[[1]]$fullExchangeName, "CME")
    expect_equal(trend[[1]]$symbol, "ES=F")
    expect_equal(trend[[1]]$quoteType, "FUTURE")
    expect_equal(trend[[1]]$regularMarketPrice$raw, 4159.25)
  })
})