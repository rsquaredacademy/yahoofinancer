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

httptest::with_mock_api({
  test_that("output from ticker asset profile is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$asset_profile

    expect_equal(trend$sector, "Technology")
    expect_equal(trend$industry, "Consumer Electronics")
    expect_equal(trend$country, "United States")
    expect_equal(trend$fullTimeEmployees, 154000)
    expect_equal(trend$auditRisk, 2)
    expect_equal(trend$boardRisk, 1)
    expect_equal(trend$compensationRisk, 9)
    expect_equal(trend$shareHolderRightsRisk, 1)
    expect_equal(trend$overallRisk, 1)
  })
})

httptest::with_mock_api({
  test_that("output from ticker calendar events is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$calendar_events

    expect_equal(trend$earningsDate, c("2022-10-26", "2022-10-31"))
    expect_equal(trend$earningsAverage, 1.26)
    expect_equal(trend$earningsLow, 1.13)
    expect_equal(trend$earningsHigh, 1.35)
    expect_equal(trend$exDividendDate, "2022-08-05")
    expect_equal(trend$dividendDate, "2022-08-11")
  })
})
