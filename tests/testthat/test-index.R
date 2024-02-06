if (requireNamespace("httptest", quietly = TRUE)) {
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
}

test_that("index are properly validated", {
  testthat::skip_on_cran()
  nse <- Index$new("^NSEI")
  expect_message(Index$new("^NSE"), "Not a valid index.")
  expect_message(nse$set_index("^NSE"), "Not a valid index.")
})
