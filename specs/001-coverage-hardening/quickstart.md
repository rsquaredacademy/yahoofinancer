# Quickstart: Test Coverage Hardening

This guide explains how to run the newly implemented tests and verify code coverage for the `yahoofinancer` package.

## Prerequisites

Ensure you have the following R packages installed:
```R
install.packages(c("testthat", "httptest2", "covr"))
```

## Running Tests

To run the full test suite in offline mode:
```R
# In R console
testthat::test_local()
```

The tests are configured to use `httptest2::without_internet()`, so they will fail if any live network requests are attempted.

## Verifying Coverage

To generate a coverage report:
```R
# In R console
cov <- covr::package_coverage()
covr::report(cov)
```

Target coverage for the following files is **90-100%**:
- `R/ticker.R`
- `R/indice.R`
- `R/tickers.R`
- `R/utils.R`

## Adding New Mocks

If you need to add tests for new API scenarios:
1. Use `httptest2::with_mock_dir("tests/testthat/samples/scenario_name", { ... })` to record a response (requires internet).
2. The response will be saved in `tests/testthat/samples/scenario_name`.
3. Subsequent runs will use the recorded sample.
