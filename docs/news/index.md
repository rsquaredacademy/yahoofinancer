# Changelog

## yahoofinancer 0.6.1

### Bug Fixes & Architectural Improvements

- **Financial Statements Restoration**: Added working
  `$get_income_statement()`, `$get_balance_sheet()`, and
  `$get_cash_flow()` methods on `Ticker` backed by Yahoo’s
  `fundamentals-timeseries` endpoint with support for
  `frequency = c("annual", "quarterly")`. Updated
  [`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)
  to return tidy tibbles with line items.
  ([\#48](https://github.com/rsquaredacademy/yahoofinancer/issues/48))
- **Unified HTTP Request Engine**: Centralized all API communication
  into a unified internal `api_request()` helper with automatic retry,
  timeout, user agent header, and structured error reporting across all
  endpoints.
  ([\#49](https://github.com/rsquaredacademy/yahoofinancer/issues/49))
- **Standardized Failure Contracts**: Multi-symbol routines
  (`Tickers$aggregate_data()`,
  [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md),
  [`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md),
  [`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md),
  [`yf_get_index_quotes()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_index_quotes.md))
  consistently warn on failed symbols and return empty tibbles matching
  documented schemas on full failure.
  ([\#50](https://github.com/rsquaredacademy/yahoofinancer/issues/50))
- **Batch Symbol Validation & Metadata Caching**:
  [`validate()`](https://yahoofinancer.rsquaredacademy.com/reference/validate.md)
  vectorizes symbol queries into a single HTTP request. `Ticker` caches
  instance metadata, invalidating on `set_symbol()`.
  ([\#51](https://github.com/rsquaredacademy/yahoofinancer/issues/51))
- **Date Hygiene & Lookback Limit Enforcement**: `get_history()`
  validates dates client-side and enforces intraday lookback boundaries
  (1m \<= 7d, 5m/15m/30m \<= 60d, 1h \<= 730d).
  [`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)
  guards against NA date inputs.
  ([\#52](https://github.com/rsquaredacademy/yahoofinancer/issues/52))
- **Hermetic Testing & Fixtures**: Redacted `httptest2` fixtures for
  financial statements and sanitized test mock surfaces.
  ([\#53](https://github.com/rsquaredacademy/yahoofinancer/issues/53))
- **Package Hygiene**: Declared `R (>= 4.1)` floor, configured `.lintr`,
  updated User-Agent to include package version.
  ([\#54](https://github.com/rsquaredacademy/yahoofinancer/issues/54))

## yahoofinancer 0.6.0

### Enhancements

- **Functional API**: Introduced
  [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md),
  [`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md),
  [`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md),
  and
  [`yf_get_index_quotes()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_index_quotes.md)
  for pipe-friendly, tidy data analysis workflows.
- **Migration to httr2**: Migrated package networking from `httr` to
  `httr2` for modern, resilient HTTP operations.

## yahoofinancer 0.5.0

CRAN release: 2026-05-21

### Bug Fixes

- Error in currency converter adjusted closing
  ([\#21](https://github.com/rsquaredacademy/yahoofinancer/issues/21))
- Error in extracting historical values for stock
  ([\#22](https://github.com/rsquaredacademy/yahoofinancer/issues/22))

### Enhancements

- **Multiple Tickers**: Get data for multiple tickers
  ([\#19](https://github.com/rsquaredacademy/yahoofinancer/issues/19),
  [\#20](https://github.com/rsquaredacademy/yahoofinancer/issues/20))
- **Unified Object Model**: Re-engineered duplicated code patterns by
  crafting a foundational `YahooFinanceBase` R6 parent class,
  modernizing object inheritance for `Ticker` and `Index` instances.
  ([\#25](https://github.com/rsquaredacademy/yahoofinancer/pull/25))
- **API Lifecycle Layer**: Integrated an explicit parameter deprecation
  infrastructure to output clean soft-deprecation warnings while
  preserving structural backward compatibility.
- **Hermetic Test Suite**: Sealed the internal testing environment
  against ambient internet variables by enforcing local offline-only
  execution boundaries (`R_CHECK_INTERNET_AVAILABILITY=FALSE`).
- **Mock Path Optimization**: Flattened extended mock JSON directory
  structures beneath the 100-character POSIX threshold to guarantee
  absolute compatibility with CRAN tarball filters.

### Other Improvements

- **Environment Masking**: Appended specialized rules to `.Rbuildignore`
  to prevent local agent logs (`.gemini/`), unit metrics
  (`coverage.html`), and build directories (`lib/`) from leaking into
  release targets.
- **Repository Sanitation**: Cleaned out empty, legacy directory paths
  inside the testing footprint to preserve overall repository layout
  health.

## yahoofinancer 0.4.0

CRAN release: 2024-11-14

This is a minor release for bug fixes and other improvements.

### Bug Fixes

- all columns in valuation measures have same
  values([\#13](https://github.com/rsquaredacademy/yahoofinancer/issues/13))
- incorrect api path used for
  quote([\#14](https://github.com/rsquaredacademy/yahoofinancer/issues/14))
- error in options
  api([\#15](https://github.com/rsquaredacademy/yahoofinancer/issues/15))

## yahoofinancer 0.3.0

CRAN release: 2024-02-03

This is a minor release for bug fixes:

- row mismatch
  ([\#3](https://github.com/rsquaredacademy/yahoofinancer/issues/3))
- cran error
  ([\#9](https://github.com/rsquaredacademy/yahoofinancer/issues/9))
- incorrect package alias
  ([\#6](https://github.com/rsquaredacademy/yahoofinancer/issues/6))

## yahoofinancer 0.2.0

CRAN release: 2023-08-09

This is a minor release to fix bugs resulting from changes in Yahoo
Finance API.

## yahoofinancer 0.1.0

CRAN release: 2022-09-13

- Added a `NEWS.md` file to track changes to the package.
