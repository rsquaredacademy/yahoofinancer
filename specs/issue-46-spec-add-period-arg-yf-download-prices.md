# Task: Add `period` Argument Support to `yf_download_prices()`

## 1. Context & Objective
Currently, `yf_download_prices()` in `R/functional_api.R` only accepts explicit `start` and `end` dates. If a user passes a relative lookback window like `period = "6mo"`, R throws an error: `unused argument (period = "6mo")`.

The goal is to update `yf_download_prices()` (and any underlying methods in `Ticker` / `Tickers` if necessary) so users can retrieve historical prices using either:
1. **Relative Lookback (`period`)**: e.g., `yf_download_prices("AAPL", period = "6mo")`
2. **Explicit Date Range (`start` / `end`)**: e.g., `yf_download_prices("AAPL", start = "2024-01-01", end = "2024-12-31")`

---

## 2. Detailed Requirements & Behavior

### 2.1 Function Signature
Update the signature in `R/functional_api.R`:
```r
yf_download_prices <- function(tickers,
                               start = NULL,
                               end = NULL,
                               interval = "1d",
                               period = NULL)
```

### 2.2 Allowed `period` Values
Valid values for `period` should match standard Yahoo Finance ranges:
* `"1d"`, `"5d"`, `"1mo"`, `"3mo"`, `"6mo"`, `"1y"`, `"2y"`, `"5y"`, `"10y"`, `"ytd"`, `"max"`

### 2.3 Parameter Precedence & Default Resolution
1. **When `period` is provided (and `start` is `NULL`)**:
   * Validate that `period` is one of the supported range strings. Throw an informative error via `stop()` or `cli::cli_abort()` if an invalid period string is passed.
   * Query the endpoint using the relative range (or pass `period` directly through to `Ticker$get_history(period = period, interval = interval)`).
2. **When `start` is provided (and `period` is `NULL`)**:
   * If `end` is `NULL`, default `end` to `Sys.Date()`.
   * Query the endpoint using explicit date bounds (`start` and `end`).
3. **When both `start` and `period` are provided**:
   * Give precedence to explicit `start`/`end` dates, and issue an informative warning (e.g., `Warning: Both 'start' and 'period' were provided. Using explicit 'start' and 'end' dates and ignoring 'period'.`).
4. **When both `start` and `period` are `NULL`**:
   * Default to `period = "1y"` (1 year of historical data).

### 2.4 Underlying R6 / API Integration
* Ensure `Ticker$get_history()` and `Tickers$get_history()` in `R/ticker.R` / `R/tickers.R` properly accept and route `period` / `range` if not already supported.
* Ensure the function returns the standard stacked, tidy `tibble` with columns:
  `symbol`, `date`, `open`, `high`, `low`, `close`, `adj_close`, `volume`.

---

## 3. Deliverables

### 3.1 Source Code Updates
1. **`R/functional_api.R`**: Update `yf_download_prices()` implementation and its `roxygen2` documentation block (`@param period`, description, and updated examples).
2. **`R/ticker.R` / `R/tickers.R`** (if applicable): Ensure underlying `get_history()` methods handle `period` cleanly.

### 3.2 Documentation Generation
Run `devtools::document()` to update `man/yf_download_prices.Rd` and `NAMESPACE`.

### 3.3 Unit Tests (`tests/testthat/test-functional_api.R`)
Add test cases using `testthat` (and `httptest2` mocks where appropriate) verifying:
* Querying with `period = "6mo"` returns data without errors.
* Querying with valid relative periods (`"1mo"`, `"1y"`, `"ytd"`).
* Passing an invalid period (e.g., `period = "100years"`) raises a clear error.
* Passing both `start` and `period` warns the user and respects `start`/`end`.
* Default behavior when no `start` or `period` is specified (returns 1 year of data).

---

## 4. Verification Checklist
- [ ] `devtools::document()` runs with no warnings.
- [ ] `devtools::test()` runs with all tests passing.
- [ ] `devtools::check(args = "--as-cran")` passes with **0 errors, 0 warnings, 0 notes**.
