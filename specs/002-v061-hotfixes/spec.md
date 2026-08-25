# Feature Specification: v0.6.1 Hotfixes & Functional Truthfulness

**Milestone**: `v0.6.1` | **Status**: Draft | **Date**: 2026-08-24  
**Issues Tracked**: #48, #49, #50, #51, #52, #53, #54, #55  
**Target Branch**: `refactor/v0.6.1-hotfixes`  

---

## 1. Summary

Milestone `v0.6.1` is a hotfix and stabilization release dedicated to resolving all critical defects and architectural inconsistencies identified in the August 2026 package review. It establishes functional truthfulness across all exported functions (specifically restoring working financial statements), unifies HTTP request handling, standardizes failure contracts, hardens date and validation parsing, sanitizes the test suite to use real `httptest2` fixtures, raises the declared R floor to `R (>= 4.1)`, and executes a CRAN release gate.

---

## 2. Requirements & Acceptance Criteria by Issue

### User Story 1 — Financial Statements Restoration (Issue #48 / F-01)
As a financial analyst using `yahoofinancer`, I need `yf_get_financials()` and the corresponding `Ticker` methods (`$get_income_statement()`, `$get_balance_sheet()`, `$get_cash_flow()`) to return real, structured financial statement tibbles rather than silently failing and returning empty tables.

- **Acceptance Criteria**:
  1. `Ticker` implements `$get_income_statement()`, `$get_balance_sheet()`, and `$get_cash_flow()`, each accepting a `frequency = c("annual", "quarterly")` argument (defaulting to `"annual"`).
  2. The underlying data is fetched from Yahoo's `fundamentals-timeseries` endpoint, parsed, and pivoted into tidy tibbles where each row represents a distinct period (annual date or quarterly date).
  3. `yf_get_financials(tickers, statement_type)` correctly returns a combined tibble with a leading `symbol` column.
  4. If a symbol fails or has no statement data, a standard warning is emitted and other symbols in the vector continue processing.
  5. Tests run hermetically with recorded `httptest2` fixtures for real symbols (`AAPL`, `GOOG`, `RELIANCE.NS`).

---

### User Story 2 — Unified HTTP & Error Handling (Issue #49 / E-01)
As a package maintainer, I need all HTTP requests in the package to flow through a single, consistent `api_request()` helper so that error parsing, timeouts, retries, and User-Agent headers are never duplicated.

- **Acceptance Criteria**:
  1. An internal `api_request()` helper is extracted that encapsulates `httr2` request construction, timeout (15s), exponential backoff retry (max 4 tries), User-Agent header, and JSON error parsing.
  2. `R/others.R` (`get_currencies`, `get_market_summary`, `get_trending`, `currency_converter`) and `R/validate.R` are refactored to use this shared helper.
  3. All four `cat("Yahoo Finance API request failed...")` calls and the user-facing typo `"Mesage:"` are completely eliminated.
  4. Error JSON paths correctly handle `$chart$error` as well as `$quoteSummary$error` or top-level `$error`.

---

### User Story 3 — Standardized Failure Contract (Issue #50 / E-02, E-05)
As a developer piping `yf_*` functions into downstream analytics, I need failed requests to consistently emit an informative warning (naming the failed symbol) and return an empty tibble with the documented schema, rather than returning disparate types (`invisible(NULL)`, raw lists, empty base data frames) or failing silently.

- **Acceptance Criteria**:
  1. `Tickers$aggregate_data()` emits a warning identifying the failed symbol instead of silently returning `NULL` via bare `tryCatch`.
  2. All functional API functions (`yf_download_prices`, `yf_get_market_stats`, `yf_get_index_quotes`, `yf_get_financials`) return empty tibbles matching documented column schemas on failure.
  3. Single-object R6 methods return `invisible(NULL)` with a standard warning on failure.
  4. All roxygen `@return` documentation tags explicitly document the failure return behavior.

---

### User Story 4 — Vectorized Batch Validation & Metadata Caching (Issue #51 / E-03)
As a user querying multiple tickers, I need `validate()` to check all symbols in a single batch request, and I need repeated property reads on a `Ticker` object to reuse cached metadata rather than initiating redundant network roundtrips.

- **Acceptance Criteria**:
  1. `validate(c("AAPL", "MSFT", "GOOG"))` issues a single HTTP request with comma-separated symbols.
  2. `Ticker` caches `meta_info()` internally on the instance and invalidates the cache when `set_symbol()` is called.
  3. Repeated reads of `ticker$quote_type`, `ticker$currency`, `ticker$exchange` trigger at most 1 network call per instance.

---

### User Story 5 — Date Hygiene & Intraday Lookback Enforcement (Issue #52 / E-04)
As a user requesting historical prices, I need invalid date formats or orphan `end` dates to be detected client-side with actionable warnings/errors, and I need intraday interval lookbacks to be validated against Yahoo's hard limits.

- **Acceptance Criteria**:
  1. `get_history(end = ...)` without `start` emits a warning or falls back cleanly with documented behavior.
  2. `currency_converter()` includes `is.na()` guards on parsed dates to prevent sending `NA` timestamps to Yahoo.
  3. Client-side validation enforces Yahoo's intraday lookback boundaries: `1m` (≤ 7 days), `5m`/`15m`/`30m` (≤ 60 days), `1h` (≤ 730 days) with informative error messages.

---

### User Story 6 — Mock-Surface Audit & Test Suite Standardization (Issue #53)
As a developer running CI, I need the test suite to exclusively use realistic `httptest2` fixtures recorded from real endpoints, preventing regressions like F-01 from being masked by synthetic mock bindings.

- **Acceptance Criteria**:
  1. `helper-mocks.R` is audited to remove any synthetic mock methods that do not exist on real R6 classes.
  2. All new tests use `httptest2` fixtures with URL redaction keeping fixture path lengths under CRAN's 100-character limit.
  3. Document testing and mocking standards in `CONTRIBUTING.md`.

---

### User Story 7 — Linting & R Floor Migration (Issue #54 / E-06)
As a CRAN package maintainer, I need the package to be formatted cleanly according to tidyverse style guides and declare an honest R version dependency floor.

- **Acceptance Criteria**:
  1. `.lintr` configuration added; package passes `lintr::lint_package()` cleanly.
  2. `DESCRIPTION` raises dependency to `Depends: R (>= 4.1)`.
  3. `httptest` (legacy) is removed from `Suggests`, keeping only `httptest2`.
  4. User-Agent header updated to `yahoofinancer/<package_version>`.
  5. Deprecated `_pkgdown.yml` keys fixed.

---

### User Story 8 — Release Hygiene & CRAN Gate (Issue #55)
As a release manager, I need the v0.6.1 release to be fully documented in `NEWS.md` and pass `R CMD check --as-cran` with 0 errors, 0 warnings, and 0 notes across Linux, Windows, and macOS.

- **Acceptance Criteria**:
  1. `NEWS.md` documents all v0.6.0 and v0.6.1 changes.
  2. `cran-comments.md` updated for submission.
  3. `devtools::check(args = "--as-cran")` achieves 0 errors / 0 warnings / 0 notes.
  4. Release tag `v0.6.1` pushed to GitHub.
