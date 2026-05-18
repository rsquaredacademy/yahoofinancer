library(testthat)
library(yahoofinancer)

test_that("get_history handles success path with period", {
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
      expect_s3_class(res, "data.frame")
      expect_equal(nrow(res), 2)
      expect_true("adj_close" %in% names(res))
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

test_that("Ticker active bindings for meta info handle success", {
  aapl <- Ticker$new("AAPL")
  
  with_mock_api(
    response_mock = mock_response(
      body_json = list(
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
    ),
    code = {
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
    }
  )
})
