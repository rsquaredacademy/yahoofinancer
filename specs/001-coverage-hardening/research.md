# Research: Test Coverage Hardening

## Decision: Mocking Framework
- Decision: Use `httptest2` and `httptest2::without_internet()` for all tests.
- Rationale: Mandatory per project Constitution (Section IV) and feature specification.
- Alternatives considered: `webmockr`, `vcr` (rejected as `httptest2` is standard for `httr2`).

## Decision: Error Handling in Tests
- Decision: Use `testthat::expect_error()` to catch errors thrown by API responses like 503 or 403, and by parsing utility functions.
- Rationale: Required by the feature spec.
- Alternatives considered: None, as this is the standard way to test errors in R.

## Decision: Partial Failure in `Tickers$aggregate_data()`
- Decision: Mock successful and failed API responses for a list of tickers to verify that the `tryCatch` block returns data for successful tickers and skips failed ones.
- Rationale: Ensures robustness when fetching multiple tickers.
- Alternatives considered: Live network tests (rejected due to hermetic testing requirement).
