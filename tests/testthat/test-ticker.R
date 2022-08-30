httptest::with_mock_api({
  test_that("output from ticker balance sheet annual is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_balance_sheet('annual')

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 24)
    expect_equal(trend$end_date,
                 as.Date(c("2021-09-25", "2020-09-26", "2019-09-28", "2018-09-29")))
  })
})

httptest::with_mock_api({
  test_that("output from ticker balance sheet quarterly is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_balance_sheet('quarter')

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 24)
    expect_equal(trend$end_date,
                 as.Date(c("2022-06-25", "2022-03-26", "2021-12-25", "2021-09-25")))
  })
})

httptest::with_mock_api({
  test_that("output from ticker cash flow annual is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_cash_flow('annual')

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 20)
    expect_equal(trend$end_date,
                 as.Date(c("2021-09-25", "2020-09-26", "2019-09-28", "2018-09-29")))
  })
})

httptest::with_mock_api({
  test_that("output from ticker cash flow quarterly is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_cash_flow('quarter')

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 20)
    expect_equal(trend$end_date,
                 as.Date(c("2022-06-25", "2022-03-26", "2021-12-25", "2021-09-25")))
  })
})

httptest::with_mock_api({
  test_that("output from ticker income statement annual is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_income_statement('annual')

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 16)
    expect_equal(trend$end_date,
                 as.Date(c("2021-09-25", "2020-09-26", "2019-09-28", "2018-09-29")))
  })
})

httptest::with_mock_api({
  test_that("output from ticker income statement quarterly is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_income_statement('quarter')

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 16)
    expect_equal(trend$end_date,
                 as.Date(c("2022-06-25", "2022-03-26", "2021-12-25", "2021-09-25")))
  })
})
