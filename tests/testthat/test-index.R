httptest::with_mock_api({
  test_that("output from index history is as expected", {
    testthat::skip_on_cran()
    nifty <- Index$new('^NSEI')
    trend <- nifty$get_history(start = '2022-07-01',
                               end = '2022-07-10',
                               interval = '1d')
    expect_equal(nrow(trend), 6)
    expect_equal(round(trend$high, 2),
                 c(15793.95, 15852.35, 16025.75, 16011.35, 16150.50, 16275.50))
    expect_equal(round(trend$close, 2),
                 c(15752.05, 15835.35, 15810.85, 15989.80, 16132.90, 16220.60))
  })
})


httptest::with_mock_api({
  test_that("output from index summary is as expected", {
    testthat::skip_on_cran()
    nifty <- Index$new('^NSEI')
    trend <- nifty$summary_detail
    expect_equal(length(trend), 54)
    expect_equal(trend$symbol, "^NSEI")
    expect_equal(trend$quoteType, "INDEX")
    expect_equal(trend$currency, "INR")
    expect_equal(trend$regularMarketPrice, 17558.9)
    expect_equal(trend$shortName, "NIFTY 50")
    expect_equal(trend$regularMarketDayHigh, 17685.85)
    expect_equal(trend$regularMarketDayLow, 17519.35)
    expect_equal(trend$fullExchangeName, "NSE")
  })
})
