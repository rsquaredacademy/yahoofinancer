# L4: unusual parsed response shapes fail gracefully; numeric reportedValue works.

test_that("api_request warns and returns NULL for a non-object JSON body", {
  for (body in list(TRUE, 1, "x")) {
    resp <- httr2::response(404, url = "https://invalid.example/audit",
      headers = list(`content-type` = "application/json"), body = raw())
    testthat::with_mocked_bindings(
      testthat::with_mocked_bindings(
        expect_warning(
          out <- yahoofinancer:::api_request("https://invalid.example/audit"),
          "Unexpected Yahoo Finance API response"
        ),
        req_perform = function(...) resp,
        resp_body_json = function(...) body,
        .package = "httr2"
      ),
      has_internet = function() TRUE,
      .package = "yahoofinancer"
    )
    expect_null(out)
  }
})

test_that("statement parser accepts a plain numeric reportedValue", {
  observation <- list(asOfDate = "2023-12-31", periodType = "12M", reportedValue = 100)
  item <- list(meta = list(type = list("annualTotalRevenue")),
               annualTotalRevenue = list(observation))
  with_api(list(timeseries = list(result = list(item))), {
    res <- Ticker$new("TEST", validate = FALSE)$get_income_statement()
  })
  expect_equal(res$total_revenue, 100)
  expect_equal(res$date, as.Date("2023-12-31"))
})

test_that("statement parser still reads reportedValue$raw and NA for raw = NULL", {
  obs <- list(
    list(asOfDate = "2022-12-31", periodType = "12M", reportedValue = list(raw = 90)),
    list(asOfDate = "2023-12-31", periodType = "12M", reportedValue = list(raw = NULL))
  )
  item <- list(meta = list(type = list("annualTotalRevenue")), annualTotalRevenue = obs)
  with_api(list(timeseries = list(result = list(item))), {
    res <- Ticker$new("TEST", validate = FALSE)$get_income_statement()
  })
  expect_equal(res$total_revenue, c(90, NA))
})
