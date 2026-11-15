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
    error = function(e) {
      warning(sprintf("Network request failed: %s", conditionMessage(e)), call. = FALSE)
      NULL
    }
  )

  if (is.null(resp)) {
    return(NULL)
  }

  parsed <- tryCatch(
    {
      # httr2 only Suggests jsonlite; our API requires its JSON parser.
      loadNamespace("jsonlite")
      httr2::resp_body_json(resp, simplifyVector = FALSE)
    },
    error = function(e) {
      warning(sprintf("Failed to parse Yahoo Finance API response as JSON: %s", conditionMessage(e)), call. = FALSE)
      NULL
    }
  )

  if (is.null(parsed)) {
    return(NULL)
  }

  # With simplifyVector = FALSE both JSON arrays and objects are lists;
  # only objects have names (including character(0) for an empty object).
  is_object <- function(x) is.list(x) && !is.null(names(x))
  if (!is_object(parsed)) {
    warning("Unexpected Yahoo Finance API response: expected a JSON object.", call. = FALSE)
    return(NULL)
  }

  envelopes <- c("chart", "quoteSummary", "timeseries", "finance",
                 "symbolsValidation", "currencies", "marketSummaryResponse",
                 "quoteResponse", "optionChain")
  for (key in intersect(names(parsed), c(envelopes, "error"))) {
    container <- parsed[[key]]
    if (is.null(container)) next
    valid <- is_object(container)
    if (valid && key != "error") {
      result <- container$result
      error <- container$error
      valid <- (is.null(result) ||
        (key == "finance" && is_object(result)) ||
        (is.list(result) && all(vapply(result, function(x) is.null(x) || is_object(x), logical(1))))) &&
        (is.null(error) || is_object(error))
    }
    if (!valid) {
      warning(sprintf("Unexpected Yahoo Finance API response: malformed '%s' envelope.", key), call. = FALSE)
      return(NULL)
    }
  }

  if (httr2::resp_is_error(resp)) {
    status <- httr2::resp_status(resp)
    err_msg <- "Unknown Error"
    errors <- c(lapply(parsed[intersect(envelopes, names(parsed))], function(x) x$error),
                list(parsed$error))
    for (error in errors) {
      for (field in c("description", "message")) {
        msg <- error[[field]]
        if (is.character(msg) && length(msg) == 1L && !is.na(msg) && nzchar(msg)) {
          err_msg <- msg
          break
        }
      }
      if (err_msg != "Unknown Error") break
    }
    warning(sprintf("Yahoo Finance API failed [%s]: %s", status, err_msg), call. = FALSE)
    return(NULL)
  }

  parsed
}
