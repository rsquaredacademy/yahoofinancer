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

httptest::with_mock_api({
  test_that("output from esg score is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$esg_scores

    expect_equal(trend$totalEsg$raw, 16.68)
    expect_equal(trend$environmentScore$raw, 0.65)
    expect_equal(trend$socialScore$raw, 6.86)
    expect_equal(trend$governanceScore$raw, 9.18)
    expect_equal(trend$esgPerformance, "UNDER_PERF")
    expect_false(trend$nuclear)
    expect_false(trend$militaryContract)
  })
})

httptest::with_mock_api({
  test_that("output from financial data is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$financial_data

    expect_equal(trend$currentPrice, 157.22)
    expect_equal(trend$recommendationMean, 1.9)
    expect_equal(trend$recommendationKey, "buy")
    expect_equal(trend$totalCashPerShare, 3.001)
    expect_equal(trend$currentRatio, 0.865)
    expect_equal(trend$revenuePerShare, 23.732)
    expect_equal(trend$revenueGrowth, 0.019)
  })
})

httptest::with_mock_api({
  test_that("output from fund bond holdings is as expected", {
    testthat::skip_on_cran()
    fund <- Ticker$new('vbmfx')
    trend <- fund$fund_bond_holdings

    expect_equal(trend$maturityCat, 7.4)
    expect_equal(trend$durationCat, 5.75)
  })
})

httptest::with_mock_api({
  test_that("output from fund bond ratings is as expected", {
    testthat::skip_on_cran()
    fund <- Ticker$new('vbmfx')
    trend <- fund$fund_bond_ratings

    expect_equal(trend$bb, 0)
    expect_equal(trend$aa, 0.0326)
    expect_equal(trend$aaa, 0.6892)
    expect_equal(round(trend$a, 4), 0.1208)
    expect_equal(trend$b, 0)
    expect_equal(round(trend$bbb, 4), 0.1581)
  })
})

httptest::with_mock_api({
  test_that("output from fund equity holdings is as expected", {
    testthat::skip_on_cran()
    fund <- Ticker$new('hasgx')
    trend <- fund$fund_equity_holdings

    expect_equal(trend$priceToEarnings, 18.95)
    expect_equal(trend$priceToBook, 4.6)
    expect_equal(trend$priceToSales, 3.29)
    expect_equal(trend$priceToCashflow, 17.95)
    expect_equal(trend$medianMarketCap, 5381.27)
    expect_equal(trend$priceToEarningsCat, 34.63)
    expect_equal(trend$priceToBookCat, 5.39)
  })
})

httptest::with_mock_api({
  test_that("output from fund ownership is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$fund_ownership

    expect_equal(nrow(trend), 18)
    expect_equal(ncol(trend), 6)
    expect_equal(colnames(trend),
                 c("report_date", "organization", "percent_held",
                   "position", "value", "percent_change"))
  })
})

httptest::with_mock_api({
  test_that("output from fund sector weightings is as expected", {
    testthat::skip_on_cran()
    fund <- Ticker$new('hasgx')
    trend <- fund$fund_section_weightings

    expect_equal(round(trend$realestate, 4), 0.0568)
    expect_equal(round(trend$basic_materials, 4), 0.0285)
    expect_equal(round(trend$technology, 4), 0.1869)
    expect_equal(round(trend$financial_services, 4), 0.061)
    expect_equal(round(trend$healthcare, 4), 0.2995)
  })
})

httptest::with_mock_api({
  test_that("output from fund top holdings is as expected", {
    testthat::skip_on_cran()
    fund <- Ticker$new('hasgx')
    trend <- fund$fund_top_holdings

    expect_equal(nrow(trend), 10)
    expect_equal(ncol(trend), 3)
    expect_equal(colnames(trend),
                 c("symbol", "holding_name", "holding_percent"))
  })
})

httptest::with_mock_api({
  test_that("output from grading history is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$grading_history

    expect_equal(nrow(trend), 855)
    expect_equal(ncol(trend), 5)
    expect_equal(colnames(trend),
                 c("date", "firm", "to_grade", "from_grade", "action"))
  })
})

httptest::with_mock_api({
  test_that("output from index trend is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$index_trend

    expect_equal(trend$symbol, "SP5")
    expect_equal(trend$pe_ratio, 17.8242)
    expect_equal(trend$peg_ratio, 1.94431)

    expect_equal(nrow(trend$estimates), 6)
    expect_equal(ncol(trend$estimates), 2)
    expect_equal(colnames(trend$estimates),
                 c("period", "growth"))
  })
})

httptest::with_mock_api({
  test_that("output from inside holders is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$inside_holders

    expect_equal(nrow(trend), 10)
    expect_equal(ncol(trend), 7)
    expect_equal(colnames(trend),
                 c('name', 'relation', 'url', 'description',
                   'latest_transaction_date', 'position_direct',
                   'position_direct_date'))
  })
})

httptest::with_mock_api({
  test_that("output from insider transactions is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$insider_transactions

    expect_equal(nrow(trend), 150)
    expect_equal(ncol(trend), 9)
    expect_equal(colnames(trend),
                 c('start_date', 'filer_name', 'filer_relation',
                 'transaction_text', 'ownership', 'shares', 'value',
                 'filer_url', 'money_text'))
  })
})

httptest::with_mock_api({
  test_that("output from institution ownership is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$institution_ownership

    expect_equal(nrow(trend), 11)
    expect_equal(ncol(trend), 6)
    expect_equal(colnames(trend),
                 c('date', 'organization', 'percent_held', 'position',
                   'value', 'percent_change'))
  })
})


httptest::with_mock_api({
  test_that("output from key stats is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$key_stats

    expect_equal(trend$enterpriseValue$fmt, "2.63T")
    expect_equal(trend$forwardPE$fmt, "24.38")
    expect_equal(trend$profitMargins$fmt, "25.71%")
    expect_equal(trend$floatShares$fmt, "16.05B")
    expect_equal(trend$bookValue$fmt, "3.61")
    expect_equal(trend$priceToBook$fmt, "43.55")
  })
})


httptest::with_mock_api({
  test_that("output from major holders is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$major_holders

    expect_equal(round(trend$insidersPercentHeld, 5), 0.00069)
    expect_equal(round(trend$institutionsPercentHeld, 5), 0.59785)
    expect_equal(round(trend$institutionsFloatPercentHeld, 5), 0.59826)
    expect_equal(trend$institutionsCount, 5492)


  })
})

httptest::with_mock_api({
  test_that("output from page views is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$page_views

    expect_equal(trend$shortTermTrend, "UP")
    expect_equal(trend$midTermTrend, "UP")
    expect_equal(trend$longTermTrend, "UP")


  })
})


httptest::with_mock_api({
  test_that("output from price is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$price

    expect_equal(trend$preMarketPrice, 156.11)
    expect_equal(trend$regularMarketPrice, 157.22)
    expect_equal(trend$regularMarketDayHigh$fmt, "160.58")
    expect_equal(trend$regularMarketDayLow$fmt, "157.14")
    expect_equal(trend$regularMarketPreviousClose$fmt, "158.91")
    expect_equal(trend$regularMarketOpen$fmt, "160.30")
    expect_equal(trend$marketCap$fmt, "2.53T")


  })
})


httptest::with_mock_api({
  test_that("output from quote type is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$quote_type

    expect_equal(trend$exchange, "NMS")
    expect_equal(trend$quoteType, "EQUITY")
    expect_equal(trend$symbol, "AAPL")
    expect_equal(trend$shortName, "Apple Inc.")

  })
})

httptest::with_mock_api({
  test_that("output from recommendation trend is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$recommendation_trend

    expect_equal(nrow(trend), 4)
    expect_equal(ncol(trend), 6)
    expect_equal(colnames(trend),
                 c("period", "strong_buy", "buy",
                   "hold", "sell", "strong_sell"))
    expect_equal(trend$period, c("0m", "-1m", "-2m", "-3m"))
    expect_equal(trend$strong_buy, c(11, 14, 14, 13))
    expect_equal(trend$buy, c(21, 24, 24, 20))
    expect_equal(trend$hold, c(6, 8, 8, 8))

  })
})
