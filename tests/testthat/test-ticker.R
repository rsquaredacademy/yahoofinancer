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

httptest::with_mock_api({
  test_that("output from ticker company officers is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$company_officers

    expect_equal(nrow(trend), 10)
    expect_equal(ncol(trend), 8)
    expect_equal(trend$name, c("Mr. Timothy D. Cook", "Mr. Luca  Maestri",
                               "Mr. Jeffrey E. Williams",
                               "Ms. Katherine L. Adams",
                               "Ms. Deirdre  O'Brien", "Mr. Chris  Kondo",
                               "Mr. James  Wilson", "Ms. Mary  Demby",
                               "Ms. Nancy  Paxton", "Mr. Greg  Joswiak"))
    expect_equal(trend$age, c(60, 57, 57, 57, 54, NA, NA, NA, NA, NA))
  })
})

httptest::with_mock_api({
  test_that("output from ticker earnings history is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$earnings_history

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 6)
    expect_equal(trend$quarter,
                 c('2021-09-30', '2021-12-31', '2022-03-31', '2022-06-30'))
    expect_equal(trend$eps_estimate, c(1.24, 1.89, 1.43, 1.16))
    expect_equal(trend$eps_actual, c(1.24, 2.10, 1.52, 1.20))
    expect_equal(trend$eps_difference, c(0.00, 0.21, 0.09, 0.04))
    expect_equal(trend$surprise_percent, c(0.000, 0.111, 0.063, 0.034))
  })
})

httptest::with_mock_api({
  test_that("output from ticker earnings is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$earnings

    expect_equal(nrow(trend$earnings_estimate), 4)
    expect_equal(ncol(trend$earnings_estimate), 3)
    expect_equal(trend$earnings_estimate$actual, c(1.24, 2.10, 1.52, 1.20))
    expect_equal(trend$earnings_estimate$estimate, c(1.24, 1.89, 1.43, 1.16))

    expect_equal(trend$current_quarter$estimate, 1.26)
    expect_equal(trend$current_quarter$estimate_year, 2022)

    expect_equal(nrow(trend$yearly_earnings_revenue), 4)
    expect_equal(ncol(trend$yearly_earnings_revenue), 3)
    expect_equal(trend$yearly_earnings_revenue$date,
                 c("2018", "2019", "2020", "2021"))

    expect_equal(nrow(trend$quarterly_earnings_revenue), 4)
    expect_equal(ncol(trend$quarterly_earnings_revenue), 3)
    expect_equal(trend$quarterly_earnings_revenue$date,
                 c("3Q2021", "4Q2021", "1Q2022", "2Q2022"))

  })
})