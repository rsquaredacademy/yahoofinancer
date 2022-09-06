httptest::with_mock_api({
  test_that("output from currency summary is as expected", {
    testthat::skip_on_cran()
    trend <- currency_summary()
    expect_equal(trend$symbol, c("USDINR=X"))
    expect_equal(length(trend), 54)
    expect_equal(trend$currency, c("INR"))
    expect_equal(trend$fiftyDayAverage, c(79.22105))
    expect_equal(trend$twoHundredDayAverage, c(76.67138))
    expect_equal(trend$regularMarketPrice, c(79.893))
  })
})

httptest::with_mock_api({
  test_that("output from currency converter is as expected", {
    testthat::skip_on_cran()

    trend <- currency_converter('GBP', 'USD', '2022-07-01', '2022-07-5', '1d')
    expect_equal(nrow(trend), 3)
    expect_equal(round(trend$high, 2), c(1.22, 1.22, 1.21))
    expect_equal(round(trend$low, 2), c(1.20, 1.21, 1.19))


    trend3 <- currency_converter(from = 'GBP',
                                 to = 'USD',
                                 period = '5d',
                                 interval = '1d')
    expect_equal(nrow(trend3), 5)
    expect_equal(round(trend3$high, 2), c(1.18, 1.17, 1.16, 1.16, 1.15))
    expect_equal(round(trend3$low, 2), c(1.16, 1.16, 1.15, 1.15, 1.14))
  })
})





