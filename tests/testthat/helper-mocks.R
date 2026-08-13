# Shared mocking functions

#' Mock httr functions
#' @param status_code HTTP status code to return
#' @param body_json List to return as JSON body
#' @param is_error Boolean, whether to return TRUE for http_error
mock_response <- function(status_code = 200, body_json = list(), is_error = FALSE) {
  list(
    status_code = status_code,
    content = body_json,
    is_error = is_error
  )
}

#' Wrapper for mocked bindings
#' @param code Code to execute with mocked bindings
#' @param response_mock Mocked response data (from mock_response)
#' @param internet_mock Function to mock curl::has_internet
with_mock_api <- function(code, response_mock = NULL, internet_mock = NULL) {
  
  if (is.null(response_mock)) {
    response_mock <- mock_response()
  }
  
  mock_req_perform <- function(req, ...) {
    if (is.list(response_mock) && !is.null(response_mock$status_code)) {
      status_code <- response_mock$status_code
      content_val <- response_mock$content
    } else {
      status_code <- 200
      content_val <- list()
    }
    
    resp <- httr2::response(
      status_code = status_code,
      url = req$url,
      headers = list(),
      body = raw()
    )
    resp$body_json <- content_val
    if (is.list(response_mock) && !is.null(response_mock$is_error)) {
      resp$is_error <- response_mock$is_error
    }
    resp
  }

  mock_resp_body_json <- function(resp, ...) {
    if (is.list(resp) && !is.null(resp$body_json)) {
      return(resp$body_json)
    }
    if (is.list(resp) && !is.null(resp$content)) {
      return(resp$content)
    }
    list()
  }

  mock_resp_is_error <- function(resp) {
    if (is.list(resp) && !is.null(resp$is_error)) {
      return(resp$is_error)
    }
    if (is.list(resp) && !is.null(resp$status_code)) {
      return(resp$status_code >= 400)
    }
    FALSE
  }

  mock_resp_status <- function(resp) {
    if (is.list(resp) && !is.null(resp$status_code)) {
      return(resp$status_code)
    }
    200
  }

  inner_code <- function() {
    testthat::with_mocked_bindings(
      testthat::with_mocked_bindings(
        code,
        req_perform = mock_req_perform,
        resp_body_json = mock_resp_body_json,
        resp_is_error = mock_resp_is_error,
        resp_status = mock_resp_status,
        .package = "yahoofinancer"
      ),
      req_perform = mock_req_perform,
      resp_body_json = mock_resp_body_json,
      resp_is_error = mock_resp_is_error,
      resp_status = mock_resp_status,
      .package = "httr2"
    )
  }

  if (!is.null(internet_mock)) {
    testthat::with_mocked_bindings(
      inner_code(),
      has_internet = internet_mock,
      .package = "curl"
    )
  } else {
    inner_code()
  }
}
