test_that("jsonlite is required and recorded bodies use the real JSON parser", {
  expect_match(utils::packageDescription("yahoofinancer")$Imports, "\\bjsonlite\\b")
  with_json_response(recorded_json("chr", "aapl-955a6a.json"), {
    parsed <- yahoofinancer:::api_request("https://invalid.example/chart")
    expect_equal(parsed$chart$result[[1]]$meta$regularMarketPrice, 155.81)
    expect_equal(parsed$chart$result[[1]]$meta$symbol, "AAPL")
  })
})

test_that("parser diagnostics retain conditionMessage for rlang errors", {
  # rlang's lazily formatted conditions need not have a useful $message.
  err <- structure(list(message = "", call = NULL),
                   class = c("yfx2_error", "error", "condition"))
  method <- "conditionMessage.yfx2_error"
  assign(method, function(c) "useful parser detail", envir = .GlobalEnv)
  on.exit(rm(list = method, envir = .GlobalEnv))
  with_json_response("{}", {
    testthat::with_mocked_bindings(
      expect_warning(
        out <- yahoofinancer:::api_request("https://invalid.example/chart"),
        "Failed to parse.*useful parser detail"
      ),
      resp_body_json = function(...) stop(err), .package = "httr2"
    )
    expect_null(out)
  })
})

test_that("real JSON arrays and malformed envelopes warn and return NULL", {
  for (body in c("true", "1", '"x"', "[1]", "[]", '[{"chart":{}}]',
                 '{"chart":1}', '{"chart":[1]}',
                 '{"chart":{"result":1}}', '{"chart":{"error":1}}')) {
    for (status in c(200L, 404L)) {
      with_json_response(body, {
        expect_warning(out <- yahoofinancer:::api_request("https://invalid.example/chart"),
                       "Unexpected Yahoo Finance API response")
        expect_null(out)
      }, status = status)
    }
  }
})

test_that("missing and NULL error fields give a clear fallback diagnostic", {
  for (body in c('{}', '{"chart":{}}', '{"chart":null}',
                 '{"chart":{"error":null}}',
                 '{"chart":{"error":{"description":null}}}',
                 '{"error":{"description":[1]}}')) {
    with_json_response(body, {
      expect_warning(out <- yahoofinancer:::api_request("https://invalid.example/chart"),
                     "Yahoo Finance API failed \\[404\\]: Unknown Error")
      expect_null(out)
    }, status = 404L)
  }
  with_json_response('{"chart":{"error":{"description":"Missing symbol"}}}', {
    expect_warning(out <- yahoofinancer:::api_request("https://invalid.example/chart"),
                   "Yahoo Finance API failed \\[404\\]: Missing symbol")
    expect_null(out)
  }, status = 404L)
})

test_that("the finance insights object result remains supported with real parsing", {
  body <- paste(readLines(test_path("samples", "insights_1.json"), warn = FALSE), collapse = "\n")
  with_json_response(body, {
    out <- Ticker$new("TEST", validate = FALSE)$technical_insights
    expect_equal(out$symbol, "MSFT")
  })
})

test_that("missing and NULL statement values become NA with missing dates skipped", {
  body <- '{"timeseries":{"result":[{"meta":{"type":["annualTotalRevenue"]},
    "annualTotalRevenue":[
      {"asOfDate":"2021-12-31","reportedValue":100},
      {"asOfDate":"2022-12-31","periodType":null,"reportedValue":null},
      {"asOfDate":"2023-12-31","periodType":"12M"},
      {"asOfDate":"2024-12-31","reportedValue":{"raw":null}},
      {"reportedValue":999}, {"asOfDate":null,"reportedValue":999}]}]}}'
  with_json_response(body, {
    out <- Ticker$new("TEST", validate = FALSE)$get_income_statement()
    expect_equal(out$total_revenue, c(100, NA_real_, NA_real_, NA_real_))
    expect_equal(out$date, as.Date(paste0(2021:2024, "-12-31")))
    expect_equal(out$period_type, c(NA_character_, NA_character_, "12M", NA_character_))
  })
})
