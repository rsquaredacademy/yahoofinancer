if (requireNamespace("httptest", quietly = TRUE)) {
  httptest::with_mock_api({
    test_that("output from currency converter is as expected", {
      testthat::skip_on_cran()

      trend <- currency_converter('GBP', 'USD', '2022-07-01', '2022-07-5', '1d')
      expect_equal(nrow(trend), 3)
      expect_equal(round(trend$high, 2), c(1.22, 1.22, 1.21))
      expect_equal(round(trend$low, 2), c(1.20, 1.21, 1.19))


      trend3 <- currency_converter(from = 'GBP',
                                   to = 'USD',
                                   period = '5d',
                                   interval = '1d')
      expect_equal(nrow(trend3), 5)
      expect_equal(round(trend3$high, 2), c(1.18, 1.17, 1.16, 1.16, 1.15))
      expect_equal(round(trend3$low, 2), c(1.16, 1.16, 1.15, 1.15, 1.14))
    })
  })
}

test_that("currency_converter retrieves exchange rate data", {
  res <- currency_converter(from = "GBP", to = "USD", period = "1mo")
  
  expect_s3_class(res, "data.frame")
  expect_true(nrow(res) > 0)
  expect_true(all(c("date", "close") %in% names(res)))
})

test_that("currency_converter handles start/end dates", {
  res <- currency_converter("EUR", "USD", start = "2023-01-01", end = "2023-01-10")
  expect_s3_class(res, "data.frame")
})

test_that("currency_converter handles API failures", {
  # Mocking a 404 error for currency conversion
  testthat::with_mocked_bindings(
    GET = function(...) list(status_code = 404),
    http_error = function(...) TRUE,
    content = function(...) '{"quoteSummary":{"error":{"code":"Not Found","description":"Invalid pairs"}}}',
    .package = "httr",
    code = {
      expect_message(currency_converter("XYZ", "ABC"))
    }
  )
})

test_that("currency_converter edge cases", {
  res <- currency_converter(from = "USD", to = "EUR", start = "2024-01-01")
  expect_s3_class(res, "data.frame")
  expect_true(max(res$date) > as.POSIXct("2024-01-01"))

  testthat::with_mocked_bindings(
    has_internet = function() FALSE,
    .package = "curl",
    code = {
      expect_message(currency_converter("USD", "EUR"), "No internet connection.")
    }
  )
})
