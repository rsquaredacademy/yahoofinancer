if (requireNamespace("httptest2", quietly = TRUE)) {
  httptest2::with_mock_api({
    test_that("get_market_summary() default returns a tbl_df / data.frame", {
      res <- get_market_summary()
      expect_s3_class(res, "tbl_df")
      expect_s3_class(res, "data.frame")
    })
    
    test_that("get_market_summary() returns required schema with correct data types", {
      res <- get_market_summary()
      expect_true(all(c("symbol", "short_name", "regular_market_price", 
                        "regular_market_change", "regular_market_change_percent", 
                        "regular_market_previous_close", "market_state", 
                        "exchange", "market_time") %in% names(res)))
      
      expect_type(res$symbol, "character")
      expect_type(res$short_name, "character")
      expect_type(res$regular_market_price, "double")
      expect_type(res$regular_market_change, "double")
      expect_type(res$regular_market_change_percent, "double")
      expect_type(res$regular_market_previous_close, "double")
      expect_type(res$market_state, "character")
      expect_type(res$exchange, "character")
      expect_s3_class(res$market_time, "POSIXct")
    })
    
    test_that("get_market_summary(as_tibble = FALSE) returns a list", {
      res <- get_market_summary(as_tibble = FALSE)
      expect_type(res, "list")
    })
    
    test_that("Direct pipe compatibility with dplyr::filter() and dplyr::select()", {
      skip_if_not_installed("dplyr")
      
      res <- get_market_summary()
      filtered <- dplyr::filter(res, !is.na(symbol))
      selected <- dplyr::select(filtered, symbol, regular_market_price)
      
      expect_s3_class(selected, "tbl_df")
      expect_equal(names(selected), c("symbol", "regular_market_price"))
    })
  })
}

test_that("Invalid inputs raise informative error", {
  expect_error(get_market_summary(as_tibble = "yes"), "`as_tibble` must be a single logical value")
  expect_error(get_market_summary(as_tibble = 123), "`as_tibble` must be a single logical value")
  expect_error(get_market_summary(as_tibble = NA), "`as_tibble` must be a single logical value")
  expect_error(get_market_summary(as_tibble = c(TRUE, FALSE)), "`as_tibble` must be a single logical value")
})

test_that('get_market_summary handles offline (as_tibble=TRUE)', {
  with_mock_api(internet_mock = function() FALSE, code = {
    expect_message(res <- get_market_summary(), 'No internet connection.')
    expect_s3_class(res, 'tbl_df')
    expect_equal(nrow(res), 0)
  })
})

test_that('get_market_summary handles offline (as_tibble=FALSE)', {
  with_mock_api(internet_mock = function() FALSE, code = {
    expect_message(res <- get_market_summary(as_tibble = FALSE), 'No internet connection.')
    expect_null(res)
  })
})

test_that('get_market_summary handles empty data', {
  with_mock_api(
    response_mock = mock_response(body_json = list(marketSummaryResponse = list(result = list()))),
    code = {
      res <- get_market_summary()
      expect_equal(nrow(res), 0)
    }
  )
})

