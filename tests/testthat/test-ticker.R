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

test_that("symbols are properly validated", {
  testthat::skip_on_cran()
  aapl <- Ticker$new("aapl")
  expect_message(Ticker$new("aapls"), "Not a valid symbol.")
  expect_message(aapl$set_symbol("aapls"), "Not a valid symbol.")
})
