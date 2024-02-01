if (requireNamespace("httptest", quietyly = TRUE)) {
  httptest::with_mock_api({
    test_that("output from trending securities is as expected", {
      testthat::skip_on_cran()
      trend <- get_trending(country = "US", count = 5)
      expect_equal(length(trend), 5)
      expect_equal(trend, c("BBBY", "PTON", "SOFI", "JWN", "STBX"))
    })
  })
}

test_that("output is as expected in case of no trending securities", {
  testthat::skip_on_cran()
  expect_message(get_trending("IN"), "No trending securities.")
})
