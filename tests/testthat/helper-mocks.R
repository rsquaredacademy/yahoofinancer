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
  
  # Default mocks
  if (is.null(response_mock)) {
    response_mock <- mock_response()
  }
  
  mock_GET <- function(...) response_mock
  
  mock_http_error <- function(resp) {
    if (is.list(resp) && !is.null(resp$is_error)) {
      return(resp$is_error)
    }
    # If it's a status code (numeric)
    if (is.numeric(resp)) {
      return(resp >= 400)
    }
    FALSE
  }
  
  mock_status_code <- function(resp) {
    if (is.list(resp) && !is.null(resp$status_code)) {
      return(resp$status_code)
    }
    resp
  }
  
  mock_content <- function(resp, as = NULL, ...) {
    if (!is.null(as) && as == "text") {
      return(jsonlite::toJSON(resp$content, auto_unbox = TRUE))
    }
    resp$content
  }
  
  # Indice.R uses http_status
  mock_http_status <- function(resp) {
    code <- if (is.list(resp)) resp$status_code else resp
    list(category = if (code >= 400) "Client error" else "Success")
  }

  inner_code <- function() {
    # Mock in httr
    testthat::with_mocked_bindings(
      # Also mock in yahoofinancer because they are imported
      testthat::with_mocked_bindings(
        code,
        GET = mock_GET,
        http_error = mock_http_error,
        status_code = mock_status_code,
        content = mock_content,
        http_status = mock_http_status,
        .package = "yahoofinancer"
      ),
      GET = mock_GET,
      http_error = mock_http_error,
      status_code = mock_status_code,
      content = mock_content,
      http_status = mock_http_status,
      .package = "httr"
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
