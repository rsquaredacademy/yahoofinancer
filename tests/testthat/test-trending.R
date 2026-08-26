library(testthat)
library(yahoofinancer)

if (requireNamespace('httptest2', quietly = TRUE)) {
  httptest2::with_mock_api({
    test_that('output from trending securities is as expected', {
      trend <- get_trending(country = 'US', count = 5)
      expect_equal(length(trend), 5)
      expect_equal(trend, c('BBBY', 'PTON', 'SOFI', 'JWN', 'STBX'))
    })
  })
}

test_that('get_trending handles empty result', {
  with_mock_api(
    response_mock = mock_response(body_json = list(finance = list(result = list()))),
    code = {
      expect_message(res <- get_trending(), 'No trending securities.')
      expect_null(res)
    }
  )
})

test_that('get_trending handles offline gracefully', {
  with_mock_api(internet_mock = function() FALSE, code = {
    expect_message(res <- get_trending(), 'No internet connection.')
    expect_null(res)
  })
})

test_that('get_trending handles API error', {
  with_mock_api(
    response_mock = mock_response(status_code = 500, is_error = TRUE),
    code = {
      expect_warning(res <- get_trending(), 'Yahoo Finance API failed \\[500\\]: Unknown Error')
      expect_null(res)
    }
  )
})
