library(testthat)
library(yahoofinancer)

# Test User Story 1 - Currency Conversion (Priority: P1)

test_that("currency_converter handles missing internet connection gracefully", {
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_message(currency_converter("EUR", "USD"), "No internet connection.")
      expect_null(currency_converter("EUR", "USD"))
    }
  )
})

test_that("currency_converter handles API failure with message", {
  with_mock_api(
    response_mock = mock_response(
      status_code = 404,
      body_json = list(quoteSummary = list(error = list(code = "NOT_FOUND", description = "Invalid pairs"))),
      is_error = TRUE
    ),
    code = {
      expect_output(currency_converter("XYZ", "ABC"), "Yahoo Finance API request failed")
      expect_null(currency_converter("XYZ", "ABC"))
    }
  )
})

test_that("currency_converter handles success path", {
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
                    open = list(1.18),
                    high = list(1.19),
                    low = list(1.17),
                    close = list(1.185),
                    volume = list(0)
                  )
                ),
                adjclose = list(
                  list(adjclose = list(1.185))
                )
              )
            )
          )
        )
      )
    ),
    code = {
      res <- currency_converter("EUR", "USD", period = "1d")
      # Note: currency_converter uses subset(result, !is.na(volume))
      # In the mock, volume is 0, which is not NA.
      # But indicators$volume in mock should be 0.
      expect_s3_class(res, "data.frame")
    }
  )
})


test_that('get_currencies handles offline gracefully', {
  with_mock_api(internet_mock = function() FALSE, code = {
    expect_message(res <- get_currencies(), 'No internet connection.')
    expect_null(res)
  })
})

test_that('get_currencies handles API error', {
  with_mock_api(
    response_mock = mock_response(status_code = 500, is_error = TRUE),
    code = {
      expect_output(res <- get_currencies(), 'Yahoo Finance API request failed')
      expect_null(res)
    }
  )
})

test_that('get_currencies returns correct schema on success', {
  with_mock_api(
    response_mock = mock_response(body_json = list(currencies = list(result = list(
      list(shortName = 'USD', longName = 'US Dollar', symbol = 'USD', localLongName = 'US Dollar'),
      list(shortName = 'EUR', longName = 'Euro', symbol = 'EUR', localLongName = 'Euro')
    )))),
    code = {
      res <- get_currencies()
      expect_s3_class(res, 'data.frame')
      expect_equal(names(res), c('short_name', 'long_name', 'symbol', 'local_long_name'))
      expect_equal(nrow(res), 2)
    }
  )
})

test_that('currency_converter handles start+end date path', {
  with_mock_api(
    response_mock = mock_response(body_json = list(chart = list(result = list(list(
      timestamp = list(1625059200),
      indicators = list(
        quote = list(list(open = list(1.18), high = list(1.19),
                          low = list(1.17), close = list(1.185), volume = list(100))),
        adjclose = list(list(adjclose = list(1.185)))
      )
    ))))),
    code = {
      res <- currency_converter('EUR', 'USD', start = '2021-07-01', end = '2021-07-02', interval = '1d')
      expect_s3_class(res, 'data.frame')
      expect_true('adj_close' %in% names(res))
    }
  )
})

test_that('currency_converter excludes adj_close for intraday intervals', {
  with_mock_api(
    response_mock = mock_response(body_json = list(chart = list(result = list(list(
      timestamp = list(1625059200),
      indicators = list(
        quote = list(list(open = list(1.18), high = list(1.19),
                          low = list(1.17), close = list(1.185), volume = list(100)))
      )
    ))))),
    code = {
      res <- currency_converter('EUR', 'USD', period = '1d', interval = '1h')
      expect_false('adj_close' %in% names(res))
    }
  )
})

test_that('currency_converter filters out NA volumes', {
  with_mock_api(
    response_mock = mock_response(body_json = list(chart = list(result = list(list(
      timestamp = list(1625059200, 1625145600),
      indicators = list(
        quote = list(list(
          open = list(1.18, 1.19), high = list(1.19, 1.20),
          low = list(1.17, 1.18), close = list(1.185, 1.195),
          volume = list(100, NULL)
        ))
      )
    ))))),
    code = {
      res <- currency_converter('EUR', 'USD', period = '5d', interval = '1d')
      expect_equal(nrow(res), 1)
    }
  )
})

