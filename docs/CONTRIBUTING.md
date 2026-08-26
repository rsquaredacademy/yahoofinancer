# Contributing to yahoofinancer

Thank you for your interest in contributing to `yahoofinancer`!

## Hermetic Testing Policy

All tests in `yahoofinancer` must run **completely offline and
hermetically**. Tests must never issue network requests to live Yahoo
Finance servers during test execution or CI.

### Mocking Mechanisms

Two testing patterns are supported:

1.  **Custom Helper `with_mock_api()`**
    (`tests/testthat/helper-mocks.R`):
    - Injects mocked HTTP responses via
      [`testthat::with_mocked_bindings`](https://testthat.r-lib.org/reference/local_mocked_bindings.html)
      on `httr2` and package internals.
    - Build responses with
      `mock_response(status_code = 200, body_json = list(...))`.
2.  **`httptest2` Fixtures** (`tests/testthat/setup-httptest2.R`):
    - Recorded JSON fixtures located in `tests/testthat/api/**`.
    - All URLs are redacted to keep file paths under CRAN’s
      100-character tarball portability limit.

## Development Workflow

Follow this standard verification workflow for any changes:

`devtools``::`[`document`](https://devtools.r-lib.org/reference/document.html)`(``)`` ``# Regenerates man/ and NAMESPACE`` ``devtools``::`[`test`](https://devtools.r-lib.org/reference/test.html)`(``)`` ``# Runs complete offline test suite`` ``devtools``::`[`check`](https://devtools.r-lib.org/reference/check.html)`(``args ``=`` ``"--as-cran"``)`` ``# Release gate (0 errors, 0 warnings, 0 notes)`

## Code Style

- Use tidyverse styling guidelines.
- Keep user-facing return values as snake_case tibbles.
- Single-ticker R6 methods warn and return `invisible(NULL)` on failure.
- Multi-ticker / batch functions warn for failed tickers and return
  empty tibbles matching documented schema on full failure.
