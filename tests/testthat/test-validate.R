library(testthat)
library(yahoofinancer)

test_that("validate single valid symbol", {
  with_mock_api(
    response_mock = mock_response(body_json = list(symbolsValidation = list(result = list(list(AAPL = TRUE))))),
    code = {
      expect_equal(validate("AAPL"), "AAPL")
      res <- validate("AAPL", return_logical = TRUE)
      expect_true(res["AAPL"])
      expect_equal(names(res), "AAPL")
    }
  )
})

test_that("validate single invalid symbol", {
  with_mock_api(
    response_mock = mock_response(body_json = list(symbolsValidation = list(result = list(list(NOTASTOCK = FALSE))))),
    code = {
      expect_equal(validate("NOTASTOCK"), character(0))
      res <- validate("NOTASTOCK", return_logical = TRUE)
      expect_false(res["NOTASTOCK"])
      expect_equal(names(res), "NOTASTOCK")
    }
  )
})

test_that("validate vectorized batch sends 1 HTTP call and handles mixed symbols", {
  call_count <- 0
  captured_query <- NULL

  mock_req_perform <- function(req, ...) {
    call_count <<- call_count + 1
    captured_query <<- req$url
    body <- list(symbolsValidation = list(result = list(
      list(AAPL = TRUE),
      list(NOTASTOCK = FALSE),
      list(MSFT = TRUE)
    )))
    resp <- httr2::response(200, url = req$url, body = raw())
    resp$body_json <- body
    resp
  }

  mock_resp_body_json <- function(resp, ...) resp$body_json
  mock_resp_is_error <- function(resp, ...) FALSE

  testthat::with_mocked_bindings(
    {
      syms <- c("AAPL", "NOTASTOCK", "MSFT")
      res <- validate(syms, return_logical = TRUE)
      expect_equal(call_count, 1)
      expect_true(grepl("AAPL,NOTASTOCK,MSFT", captured_query) || grepl("AAPL%2CNOTASTOCK%2CMSFT", captured_query))
      expect_equal(names(res), syms)
      expect_equal(as.logical(res), c(TRUE, FALSE, TRUE))

      res_char <- validate(syms, return_logical = FALSE)
      expect_equal(res_char, c("AAPL", "MSFT"))
    },
    req_perform = mock_req_perform,
    resp_body_json = mock_resp_body_json,
    resp_is_error = mock_resp_is_error,
    .package = "httr2"
  )
})

test_that("validate handles edge cases", {
  expect_warning(res <- validate(character(0)), "empty or missing")
  expect_equal(res, character(0))

  expect_warning(res_logical <- validate(character(0), return_logical = TRUE), "empty or missing")
  expect_equal(res_logical, logical(0))

  expect_warning(res_null <- validate(NULL), "empty or missing")
  expect_equal(res_null, character(0))

  expect_warning(res_num <- validate(123), "must be a character vector")
  expect_equal(res_num, character(0))

  with_mock_api(
    response_mock = mock_response(body_json = list(symbolsValidation = list(result = list(list(AAPL = TRUE), list(MSFT = TRUE))))),
    code = {
      # NA handling
      res_na <- validate(c("AAPL", NA, "MSFT"), return_logical = TRUE)
      expect_equal(names(res_na), c("AAPL", NA, "MSFT"))
      expect_equal(as.logical(res_na), c(TRUE, FALSE, TRUE))

      res_na_false <- validate(c("AAPL", NA, "MSFT"), return_logical = FALSE)
      expect_equal(res_na_false, c("AAPL", "MSFT"))
    }
  )
})

test_that("validate handles missing internet connection", {
  with_mock_api(
    internet_mock = function() FALSE,
    code = {
      expect_message(res <- validate("AAPL"), "No internet connection.")
      expect_equal(res, character(0))

      expect_message(res_logical <- validate("AAPL", return_logical = TRUE), "No internet connection.")
      expect_equal(res_logical, setNames(FALSE, "AAPL"))
    }
  )
})

test_that("validate handles API failure gracefully without aborting", {
  mock_req_perform <- function(req, ...) {
    if (grepl("FAIL", req$url)) {
      resp <- httr2::response(500, url = req$url, body = raw())
      resp$is_error <- TRUE
      resp$body_json <- list(quoteSummary = list(error = list(code = "ERR", description = "Error")))
      resp
    } else {
      resp <- httr2::response(200, url = req$url, body = raw())
      resp$is_error <- FALSE
      resp$body_json <- list(symbolsValidation = list(result = list(list(AAPL = TRUE))))
      resp
    }
  }

  mock_resp_body_json <- function(resp, ...) resp$body_json
  mock_resp_is_error <- function(resp, ...) resp$is_error

  testthat::with_mocked_bindings(
    {
      syms <- c("FAIL")
      expect_warning(res <- validate(syms, return_logical = TRUE), "Yahoo Finance API failed")
      expect_equal(names(res), syms)
      expect_equal(as.logical(res), FALSE)

      expect_warning(res_false <- validate(syms, return_logical = FALSE), "Yahoo Finance API failed")
      expect_equal(res_false, character(0))
    },
    req_perform = mock_req_perform,
    resp_body_json = mock_resp_body_json,
    resp_is_error = mock_resp_is_error,
    .package = "httr2"
  )
})

test_that("validate supports deprecation of index parameter", {
  with_mock_api(
    response_mock = mock_response(body_json = list(symbolsValidation = list(result = list(list(result = TRUE))))),
    code = {
      expect_warning(res <- validate(index = "^NSEI"), "The 'index' parameter is deprecated")
      expect_equal(res, "^NSEI")
    }
  )
})
