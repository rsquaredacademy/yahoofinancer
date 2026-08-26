#' Internal API Request Engine
#'
#' @description
#' Centralized function to dispatch HTTP GET requests to Yahoo Finance endpoints
#' with retry, timeout, user agent, and unified error handling.
#'
#' @param url Full URL to request.
#' @param query Named list of query parameters.
#' @param headers Named list of additional HTTP headers.
#'
#' @return A parsed JSON list on success, or \code{NULL} on failure.
#' @keywords internal
#' @noRd
api_request <- function(url, query = list(), headers = list()) {
  if (!has_internet()) {
    message("No internet connection.")
    return(NULL)
  }

  req <- httr2::request(url)
  ua <- paste0("yahoofinancer/", as.character(utils::packageVersion("yahoofinancer")))
  req <- httr2::req_user_agent(req, ua)

  if (length(headers) > 0) {
    req <- do.call(httr2::req_headers, c(list(req), headers))
  }

  if (length(query) > 0) {
    req <- do.call(httr2::req_url_query, c(list(req), query))
  }

  req <- httr2::req_retry(req, max_tries = 4, backoff = function(re_try) 2^re_try)
  req <- httr2::req_timeout(req, 15)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) NULL
  )

  if (is.null(resp)) return(NULL)

  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) list()
  )

  if (httr2::resp_is_error(resp)) {
    status <- httr2::resp_status(resp)
    err_msg <- if (!is.null(parsed$chart$error$description)) {
      parsed$chart$error$description
    } else if (!is.null(parsed$quoteSummary$error$description)) {
      parsed$quoteSummary$error$description
    } else if (!is.null(parsed$timeseries$error$description)) {
      parsed$timeseries$error$description
    } else if (!is.null(parsed$finance$error$description)) {
      parsed$finance$error$description
    } else if (!is.null(parsed$error$description)) {
      parsed$error$description
    } else if (!is.null(parsed$error$message)) {
      parsed$error$message
    } else {
      "Unknown Error"
    }
    warning(sprintf("Yahoo Finance API failed [%s]: %s", status, err_msg), call. = FALSE)
    return(NULL)
  }

  return(parsed)
}
