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

