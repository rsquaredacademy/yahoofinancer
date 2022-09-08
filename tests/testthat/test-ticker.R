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

httptest::with_mock_api({
  test_that("output from security filings is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$security_filings

    expect_equal(nrow(trend), 40)
    expect_equal(ncol(trend), 4)
    expect_equal(colnames(trend),
                 c('date', 'type', 'title', 'edgar_url'))
  })
})

httptest::with_mock_api({
  test_that("output from share purchase activity is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$share_purchase_activity

    expect_equal(trend$period, "6m")
    expect_equal(trend$buyInfoCount, 276)
    expect_equal(trend$sellInfoCount, 199)
    expect_equal(trend$netInfoCount, 475)
  })
})

httptest::with_mock_api({
  test_that("output from summary details is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$summary_detail

    expect_equal(trend$previousClose, 158.91)
    expect_equal(trend$open, 160.305)
    expect_equal(trend$dayLow, 157.14)
    expect_equal(trend$dayHigh, 160.58)
    expect_equal(trend$dividendRate, 0.92)
    expect_equal(trend$dividendYield, 0.0058)
    expect_equal(trend$payoutRatio, 0.1471)
    expect_equal(trend$beta, 1.230174)

  })
})

httptest::with_mock_api({
  test_that("output from summary profile is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$summary_profile

    expect_equal(trend$sector, "Technology")
    expect_equal(trend$industry, "Consumer Electronics")
    expect_equal(trend$country, "United States")
    expect_equal(trend$fullTimeEmployees, 154000)
  })
})

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

httptest::with_mock_api({
  test_that("output from get history is as expected when using range", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$get_history(period = '5d', interval = '1d')

    expect_equal(nrow(trend), 5)
    expect_equal(as.Date(trend$date), as.Date(c("2022-08-29", "2022-08-30", "2022-08-31", "2022-09-01", "2022-09-02")))
    expect_equal(round(trend$high, 2), c(162.90, 162.56, 160.58, 158.42, 160.36))
    expect_equal(round(trend$low, 2), c(159.82, 157.72, 157.14, 154.67, 154.97))
    expect_equal(round(trend$open, 2), c(161.15, 162.13, 160.31, 156.64, 159.75))
    expect_equal(round(trend$close, 2), c(161.38, 158.91, 157.22, 157.96, 155.81))
  })
})

httptest::with_mock_api({
  test_that("output from earnings trend is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$earnings_trend

    expect_equal(nrow(trend$growth), 6)
    expect_equal(trend$growth$period, c("0q", "+1q", "0y", "+1y", "+5y", "-5y"))
    expect_equal(round(trend$growth$growth, 3),
                 c(0.016, 0.010, 0.087, 0.057, 0.095, 0.235))

    expect_equal(nrow(trend$earnings_estimate), 6)
    expect_equal(trend$earnings_estimate$analyst, c(27, 23, 38, 38, NA, NA))
    expect_equal(trend$earnings_estimate$avg_estimate,
                 c(1.26, 2.12, 6.10, 6.45, NA, NA))
    expect_equal(trend$earnings_estimate$low_estimate,
                 c(1.13, 2.01, 5.96, 5.79, NA, NA))
    expect_equal(trend$earnings_estimate$year_ago_eps,
                 c(1.24, 2.10, 5.61, 6.10, NA, NA))

    expect_equal(nrow(trend$revenue_estimate), 6)
    expect_equal(trend$revenue_estimate$analyst, c(24, 20, 37, 37, NA, NA))

    expect_equal(nrow(trend$eps_trend), 6)
    expect_equal(trend$eps_trend$current,
                 c(1.26, 2.12, 6.10, 6.45, NA, NA))
    expect_equal(trend$eps_trend$seven_days_ago,
                 c(1.26, 2.12, 6.10, 6.45, NA, NA))
    expect_equal(trend$eps_trend$ninety_days_ago,
                 c(1.33, 2.19, 6.14, 6.56, NA, NA))

    expect_equal(nrow(trend$eps_revision), 6)
    expect_equal(trend$eps_revision$up_last_7_days, c(2, 1, 2, 3, NA, NA))
    expect_equal(trend$eps_revision$up_last_30_days, c(6, 5, 11, 11, NA, NA))
    expect_equal(trend$eps_revision$down_last_30_days, c(0, 0, 2, 1, NA, NA))
  })
})

httptest::with_mock_api({
  test_that("output from fund holding info is as expected", {
    testthat::skip_on_cran()
    hasgx <- Ticker$new('hasgx')
    trend <- hasgx$fund_holding_info

    expect_equal(round(trend$cash_position, 4), 0.0384)
    expect_equal(round(trend$stock_position, 4), 0.9579)
    expect_equal(round(trend$other_position, 4), 0.0038)
    expect_equal(nrow(trend$holdings), 10)
    expect_equal(round(trend$holdings$holding, 4),
                 c(0.0276, 0.0264, 0.0257, 0.0246, 0.0242,
                   0.0241, 0.024, 0.0234, 0.0216, 0.0207))
    expect_equal(round(trend$equity_holdings$priceToEarnings, 4), 18.95)
    expect_equal(round(trend$equity_holdings$priceToSales, 4), 3.29)
  })
})

httptest::with_mock_api({
  test_that("output from fund performance is as expected", {
    testthat::skip_on_cran()
    hasgx <- Ticker$new('hasgx')
    trend <- hasgx$fund_performance

    expect_equal(round(trend$performance_overview$ytdReturnPct, 4), 0.1441)
    expect_equal(round(trend$performance_overview_cat$fiveYrAvgReturnPct, 4),
                 0.2072)
    expect_equal(round(trend$load_adjusted_returns$threeYear, 4), 0.2201)
    expect_equal(round(trend$trailing_returns$lastBullMkt, 4), 0.2784)
    expect_equal(round(trend$trailing_returns_cat$lastBullMkt, 4), 0.2785)
    expect_equal(nrow(trend$annual_total_returns), 21)
    expect_equal(nrow(trend$annual_total_returns_cat), 74)
    expect_equal(nrow(trend$past_quarterly_returns), 21)
    expect_equal(ncol(trend$past_quarterly_returns), 5)
    expect_equal(trend$risk_rating, 3)
    expect_equal(nrow(trend$risk_statistics_cat), 3)
    expect_equal(ncol(trend$risk_statistics_cat), 8)
    expect_equal(round(trend$risk_statistics_cat$treynor_ratio, 4),
                 c(0.1666, 0.1506, 0.1137))
  })
})

httptest::with_mock_api({
  test_that("output from option chain is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$option_chain

    expect_equal(nrow(trend), 1711)
    expect_equal(ncol(trend), 16)

  })
})

httptest::with_mock_api({
  test_that("output from option expiration dates is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$option_expiration_dates

    expect_equal(length(trend), 18)
    expect_equal(trend[1], as.Date("2022-09-09"))
    expect_equal(trend[18], as.Date("2024-06-21"))

  })
})


httptest::with_mock_api({
  test_that("output from option strikes is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$option_strikes

    expect_equal(length(trend), 143)
    expect_equal(trend[1], 30.00)
    expect_equal(trend[139], 720.00)

  })
})

httptest::with_mock_api({
  test_that("output from quote is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$quote

    expect_equal(trend$regularMarketPrice, 154.53)
    expect_equal(trend$exchange, "NMS")
    expect_equal(trend$preMarketPrice, 155.34)

  })
})

httptest::with_mock_api({
  test_that("output from technical insights is as expected", {
    testthat::skip_on_cran()
    aapl <- Ticker$new('aapl')
    trend <- aapl$technical_insights

    expect_equal(trend$instrumentInfo$technicalEvents$sector, "Technology")
    expect_equal(trend$instrumentInfo$technicalEvents$shortTermOutlook$direction,
                 "Bearish")
    expect_equal(trend$instrumentInfo$technicalEvents$intermediateTermOutlook$direction,
                 "Bullish")
    expect_equal(trend$instrumentInfo$technicalEvents$longTermOutlook$direction,
                 "Bearish")
    expect_equal(round(trend$instrumentInfo$keyTechnicals$support, 2), 148.48)
    expect_equal(round(trend$instrumentInfo$keyTechnicals$resistance, 2), 166.33)
    expect_equal(round(trend$instrumentInfo$keyTechnicals$stopLoss, 2), 146.22)
    expect_equal(trend$instrumentInfo$valuation$relativeValue, "Premium")
    expect_equal(trend$recommendation$rating, "BUY")
    expect_equal(round(trend$recommendation$targetPrice, 2), 200)


  })
})


test_that("symbols are properly validated", {
  testthat::skip_on_cran()
  aapl <- Ticker$new("aapl")
  expect_error(Ticker$new("aapls"), "Not a valid symbol.")
  expect_error(aapl$set_symbol("aapls"), "Not a valid symbol.")
})

test_that("output from fund profile is as expected", {
  testthat::skip_on_cran()
  hasgx <- Ticker$new('hasgx')
  trend <- hasgx$fund_profile
  expect_equal(trend$family, "Harbor")
})

httptest::with_mock_api({
  test_that("output from fund holding is as expected", {
    testthat::skip_on_cran()
    hasgx <- Ticker$new('hasgx')
    trend <- hasgx$fund_holdings

    expect_equal(round(trend$cashPosition, 4), 0.0384)
    expect_equal(round(trend$stockPosition, 4), 0.9579)
    expect_equal(round(trend$otherPosition, 4), 0.0038)
  })
})
