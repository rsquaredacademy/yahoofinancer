library(testthat)
library(yahoofinancer)

test_that("get_history handles success path with period, 8-col schema, and adj_close parsing", {
  aapl <- Ticker$new("AAPL")

  with_mock_api(
    response_mock = mock_response(
      body_json = list(
        chart = list(
          result = list(
            list(
              timestamp = list(1625059200, 1625145600),
              indicators = list(
                quote = list(
                  list(
                    open = list(135.0, 136.0),
                    high = list(137.0, 138.0),
                    low = list(134.0, 135.0),
                    close = list(136.0, 137.0),
                    volume = list(1000000, 1100000)
                  )
                ),
                adjclose = list(
                  list(adjclose = list(135.5, 136.5))
                )
              )
            )
          )
        )
      )
    ),
    code = {
      res <- aapl$get_history(period = "1mo", interval = "1d")
      expect_s3_class(res, "tbl_df")
      expect_equal(names(res), c("symbol", "date", "open", "high", "low", "close", "adj_close", "volume"))
      expect_equal(nrow(res), 2)
      expect_type(res$adj_close, "double")
      expect_equal(res$adj_close, c(135.5, 136.5))

      # Pipe compatibility
      res_mutated <- res %>% dplyr::mutate(daily_return = (adj_close / dplyr::lag(adj_close)) - 1)
      expect_true("daily_return" %in% names(res_mutated))
      expect_equal(res_mutated$daily_return[2], (136.5 / 135.5) - 1)
    }
  )
})

test_that("get_history enforces adj_close fallback when absent", {
  aapl <- Ticker$new("AAPL")

  with_mock_api(
    response_mock = mock_response(
      body_json = list(
        chart = list(
          result = list(
            list(
              timestamp = list(1625059200, 1625145600),
              indicators = list(
                quote = list(
                  list(
                    open = list(135.0, 136.0),
                    high = list(137.0, 138.0),
                    low = list(134.0, 135.0),
                    close = list(136.0, 137.0),
                    volume = list(1000000, 1100000)
                  )
                )
              )
            )
          )
        )
      )
    ),
    code = {
      res <- aapl$get_history(period = "1mo", interval = "1d")
      expect_equal(names(res), c("symbol", "date", "open", "high", "low", "close", "adj_close", "volume"))
      expect_equal(res$adj_close, res$close)
    }
  )
})

test_that("get_history handles success path with start/end", {
  aapl <- Ticker$new("AAPL")

  with_mock_api(
    response_mock = mock_response(
      body_json = list(
        chart = list(
          result = list(
            list(
              timestamp = list(1625059200),
              indicators = list(
                quote = list(
                  list(
                    open = list(135.0),
                    high = list(137.0),
                    low = list(134.0),
                    close = list(136.0),
                    volume = list(1000000)
                  )
                )
              )
            )
          )
        )
      )
    ),
    code = {
      res <- aapl$get_history(start = "2021-07-01", end = "2021-07-02")
      expect_s3_class(res, "data.frame")
      expect_equal(nrow(res), 1)
    }
  )
})

test_that("valuation_measures handles success path", {
  aapl <- Ticker$new("AAPL")

  with_mock_api(
    response_mock = mock_response(
      body_json = list(
        timeseries = list(
          result = list(
            list(
              timestamp = list(1625059200),
              quarterlyMarketCap = list(list(reportedValue = list(raw = 2e12))),
              quarterlyEnterpriseValue = list(list(reportedValue = list(raw = 2.1e12))),
              quarterlyPeRatio = list(list(reportedValue = list(raw = 30.0))),
              quarterlyForwardPeRatio = list(list(reportedValue = list(raw = 28.0))),
              quarterlyPegRatio = list(list(reportedValue = list(raw = 1.5))),
              quarterlyPsRatio = list(list(reportedValue = list(raw = 7.0))),
              quarterlyPbRatio = list(list(reportedValue = list(raw = 12.0))),
              quarterlyEnterprisesValueRevenueRatio = list(list(reportedValue = list(raw = 6.5))),
              quarterlyEnterprisesValueEBITDARatio = list(list(reportedValue = list(raw = 20.0)))
            )
          )
        )
      )
    ),
    code = {
      res <- aapl$valuation_measures
      expect_s3_class(res, "data.frame")
      expect_equal(nrow(res), 1)
    }
  )
})

test_that("recommendations handles success path", {
  aapl <- Ticker$new("AAPL")

  with_mock_api(
    response_mock = mock_response(
      body_json = list(
        finance = list(
          result = list(
            list(
              recommendedSymbols = list(
                list(symbol = "MSFT", score = 0.9),
                list(symbol = "GOOGL", score = 0.8)
              )
            )
          )
        )
      )
    ),
    code = {
      res <- aapl$recommendations
      expect_s3_class(res, "data.frame")
      expect_equal(nrow(res), 2)
    }
  )
})

test_that("technical_insights handles success path", {
  aapl <- Ticker$new("AAPL")

  with_mock_api(
    response_mock = mock_response(
      body_json = list(
        finance = list(
          result = list(
            list(
              instrumentInfo = list(technicalInsights = list(sigDev = "Bullish"))
            )
          )
        )
      )
    ),
    code = {
      res <- aapl$technical_insights
      expect_type(res, "list")
    }
  )
})

test_that("Ticker active bindings for meta info handle success and cache results", {
  aapl <- Ticker$new("AAPL")

  call_count <- 0
  mock_req_perform <- function(req, ...) {
    if (grepl("validate", req$url)) {
      resp <- httr2::response(200, url = req$url, body = raw())
      resp$body_json <- list(symbolsValidation = list(result = list(list(AAPL = TRUE), list(MSFT = TRUE))))
      return(resp)
    }

    call_count <<- call_count + 1
    resp <- httr2::response(200, url = req$url, body = raw())
    resp$body_json <- list(
      chart = list(
        result = list(
          list(
            meta = list(
              currency = "USD",
              exchangeName = "Nasdaq",
              fullExchangeName = "NasdaqGS",
              firstTradeDate = 345600,
              regularMarketTime = 1625059200,
              timezone = "EDT",
              exchangeTimezoneName = "America/New_York",
              regularMarketPrice = 135.0,
              fiftyTwoWeekHigh = 150.0,
              fiftyTwoWeekLow = 100.0,
              regularMarketDayHigh = 136.0,
              regularMarketDayLow = 134.0,
              regularMarketVolume = 1000000,
              previousClose = 134.5
            )
          )
        )
      )
    )
    resp
  }

  mock_resp_body_json <- function(resp, ...) resp$body_json
  mock_resp_is_error <- function(resp, ...) FALSE

  testthat::with_mocked_bindings(
    {
      expect_equal(aapl$currency, "USD")
      expect_equal(aapl$exchange_name, "Nasdaq")
      expect_equal(aapl$full_exchange_name, "NasdaqGS")
      expect_s3_class(aapl$first_trade_date, "POSIXct")
      expect_s3_class(aapl$regular_market_time, "POSIXct")
      expect_equal(aapl$timezone, "EDT")
      expect_equal(aapl$exchange_timezone_name, "America/New_York")
      expect_equal(aapl$regular_market_price, 135.0)
      expect_equal(aapl$fifty_two_week_high, 150.0)
      expect_equal(aapl$fifty_two_week_low, 100.0)
      expect_equal(aapl$regular_market_day_high, 136.0)
      expect_equal(aapl$regular_market_day_low, 134.0)
      expect_equal(aapl$regular_market_volume, 1000000)
      expect_equal(aapl$previous_close, 134.5)

      # Crucial: Metadata read 14 properties but should only have made 1 HTTP call!
      expect_equal(call_count, 1)

      # Invalidate cache when changing symbol
      aapl$set_symbol("MSFT")
      expect_equal(aapl$currency, "USD")
      expect_equal(call_count, 2)
    },
    req_perform = mock_req_perform,
    resp_body_json = mock_resp_body_json,
    resp_is_error = mock_resp_is_error,
    .package = "httr2"
  )
})

test_that("Ticker financial statement methods return tidy tibbles with line items", {
  aapl <- Ticker$new("AAPL")

  inc_mock <- list(
    timeseries = list(
      result = list(
        list(
          meta = list(symbol = list("AAPL"), type = list("annualTotalRevenue")),
          annualTotalRevenue = list(
            list(asOfDate = "2021-09-25", periodType = "12M", reportedValue = list(raw = 365817000000)),
            list(asOfDate = "2022-09-24", periodType = "12M", reportedValue = list(raw = 394328000000)),
            list(asOfDate = "2023-09-30", periodType = "12M", reportedValue = list(raw = 383285000000))
          )
        ),
        list(
          meta = list(symbol = list("AAPL"), type = list("annualOperatingIncome")),
          annualOperatingIncome = list(
            list(asOfDate = "2021-09-25", periodType = "12M", reportedValue = list(raw = 108949000000)),
            list(asOfDate = "2022-09-24", periodType = "12M", reportedValue = list(raw = 119437000000)),
            list(asOfDate = "2023-09-30", periodType = "12M", reportedValue = list(raw = 114301000000))
          )
        )
      )
    )
  )

  with_mock_api(
    response_mock = mock_response(body_json = inc_mock),
    code = {
      inc <- aapl$get_income_statement(frequency = "annual")
      expect_s3_class(inc, "tbl_df")
      expect_equal(nrow(inc), 3)
      expect_equal(names(inc), c("date", "period_type", "total_revenue", "operating_income"))
      expect_s3_class(inc$date, "Date")
      expect_equal(inc$total_revenue[1], 365817000000)
      expect_equal(inc$operating_income[1], 108949000000)
    }
  )

  bs_mock <- list(
    timeseries = list(
      result = list(
        list(
          meta = list(symbol = list("AAPL"), type = list("quarterlyTotalAssets")),
          quarterlyTotalAssets = list(
            list(asOfDate = "2023-06-30", periodType = "3M", reportedValue = list(raw = 335000000000)),
            list(asOfDate = "2023-09-30", periodType = "3M", reportedValue = list(raw = 352000000000))
          )
        ),
        list(
          meta = list(symbol = list("AAPL"), type = list("quarterlyWorkingCapital")),
          quarterlyWorkingCapital = list(
            list(asOfDate = "2023-06-30", periodType = "3M", reportedValue = list(raw = 10000000000)),
            list(asOfDate = "2023-09-30", periodType = "3M", reportedValue = list(raw = 12000000000))
          )
        )
      )
    )
  )

  with_mock_api(
    response_mock = mock_response(body_json = bs_mock),
    code = {
      bs <- aapl$get_balance_sheet(frequency = "quarterly")
      expect_s3_class(bs, "tbl_df")
      expect_equal(nrow(bs), 2)
      expect_equal(names(bs), c("date", "period_type", "total_assets", "working_capital"))
      expect_equal(bs$total_assets[2], 352000000000)
    }
  )

  cf_mock <- list(
    timeseries = list(
      result = list(
        list(
          meta = list(symbol = list("AAPL"), type = list("annualOperatingCashFlow")),
          annualOperatingCashFlow = list(
            list(asOfDate = "2023-09-30", periodType = "12M", reportedValue = list(raw = 110543000000))
          )
        ),
        list(
          meta = list(symbol = list("AAPL"), type = list("annualFreeCashFlow")),
          annualFreeCashFlow = list(
            list(asOfDate = "2023-09-30", periodType = "12M", reportedValue = list(raw = 99584000000))
          )
        )
      )
    )
  )

  with_mock_api(
    response_mock = mock_response(body_json = cf_mock),
    code = {
      cf <- aapl$get_cash_flow(frequency = "annual")
      expect_s3_class(cf, "tbl_df")
      expect_equal(nrow(cf), 1)
      expect_equal(names(cf), c("date", "period_type", "operating_cash_flow", "free_cash_flow"))
      expect_equal(cf$free_cash_flow[1], 99584000000)
    }
  )
})
