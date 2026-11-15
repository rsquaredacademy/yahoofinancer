# Replace transport only: keep httr2's real JSON parser and status handling.
with_json_response <- function(body, code, status = 200L) {
  testthat::with_mocked_bindings(
    testthat::with_mocked_bindings(
      force(code),
      req_perform = function(req, ...) httr2::response(
        status, url = req$url,
        headers = list(`content-type` = "application/json"),
        body = charToRaw(body)
      ),
      .package = "httr2"
    ),
    has_internet = function() TRUE,
    .package = "yahoofinancer"
  )
}

recorded_json <- function(...) {
  paste(readLines(test_path("api", ...), warn = FALSE), collapse = "\n")
}
