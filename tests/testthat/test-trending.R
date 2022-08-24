httptest::with_mock_api({
  test_that("output from trending securities is as expected", {
    testthat::skip_on_cran()
    trend <- get_trending(country = "US", count = 5)
    expect_equal(length(trend), 5)
    expect_equal(trend, c("BBBY", "PTON", "SOFI", "JWN", "STBX"))
  })
})
