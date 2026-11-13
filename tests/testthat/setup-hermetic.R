# Suite-wide network blocker (audit H5). Every test runs with the HTTP transport
# replaced by a function that fails locally, and with connectivity reported as
# TRUE so results never depend on the machine being online. Tests install their
# own mocks (with_mock_api(), httptest2) inside this blocker; any request that
# escapes them fails here instead of reaching Yahoo.
.network_attempts <- new.env(parent = emptyenv())
.network_attempts$n <- 0L

block_transport <- function(...) {
  .network_attempts$n <- .network_attempts$n + 1L
  stop("Unmocked network request blocked in tests.", call. = FALSE)
}

# Block at the curl transport (below httr2's mocking hooks), so httptest2 and
# with_mock_api() still intercept requests first.
testthat::local_mocked_bindings(
  curl_fetch_memory = block_transport,
  curl_fetch_disk = block_transport,
  curl_fetch_stream = block_transport,
  .package = "curl",
  .env = testthat::teardown_env()
)
testthat::local_mocked_bindings(
  has_internet = function() TRUE,
  .package = "yahoofinancer",
  .env = testthat::teardown_env()
)
