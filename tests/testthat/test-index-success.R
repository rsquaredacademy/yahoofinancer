library(testthat)
library(yahoofinancer)

test_that("Index$get_history handles success path", {
  nifty <- Index$new("^NSEI")
  
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
                    open = list(15000.0),
                    high = list(15100.0),
                    low = list(14900.0),
                    close = list(15050.0),
                    volume = list(500000)
                  )
                ),
                adjclose = list(
                  list(adjclose = list(15050.0))
                )
              )
            )
          )
        )
      )
    ),
    code = {
      res <- nifty$get_history(period = "1d", interval = "1d")
      expect_s3_class(res, "data.frame")
      expect_equal(nrow(res), 1)
      expect_true("adj_close" %in% names(res))
    }
  )
})
