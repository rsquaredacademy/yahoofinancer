# Task: Standardize Adjusted Close (`adj_close`) in Chart Price Parser

## 1. Problem Statement & Context
Historical price downloads currently fail to return or consistently map the Adjusted Close column (`adj_close`), causing downstream quantitative calculations (e.g., returns, volatility, beta) to fail with:
`object 'adj_close' not found`.

In the Yahoo Finance Chart endpoint (`/v8/finance/chart/{symbol}`), adjusted close is located under `result$indicators$adjclose[[1]]$adjclose`, distinct from raw OHLCV under `result$indicators$quote[[1]]`. The internal parser must be updated to extract this vector and enforce a standardized 8-column schema across all price extraction interfaces.

---

## 2. Thought Process & Execution Logging Requirement
Before and during your implementation, maintain a detailed, running log in `specs/fix-parser-adj-close.log.md` covering:
1. **Assessment & Plan**: Audit current parser implementation locations across functional and R6 classes (`yf_download_prices()`, `Ticker$get_history()`, `Tickers$get_history()`, `Index$get_history()`).
2. **Implementation Decisions**: Parser unification strategy, fallback logic for missing `adjclose`, and column ordering/naming.
3. **Execution Steps**: Log of exact file edits, test updates, and documentation modifications.
4. **Verification**: Console outputs from `devtools::document()`, `devtools::test()`, and `devtools::check(args = "--as-cran")`.

---

## 3. Key Architectural Requirements

1. **Standardized 8-Column Schema**:
   All historical price functions and R6 history methods must return a tidy `tibble` containing exactly:
   * `symbol` (`character`)
   * `date` (`POSIXct` / UTC)
   * `open` (`numeric`)
   * `high` (`numeric`)
   * `low` (`numeric`)
   * `close` (`numeric`)
   * `adj_close` (`numeric`)
   * `volume` (`numeric`)

2. **Unified Parsing Engine**:
   Ensure `yf_download_prices()`, `Ticker$get_history()`, `Tickers$get_history()`, and `Index$get_history()` route through a shared parsing helper (e.g., `parse_chart_data()`) to prevent schema drift.

3. **Safe Null & Length Fallback**:
   * Extract `result$indicators$adjclose[[1]]$adjclose`.
   * If `adjclose` is missing, `NULL`, or length-mismatched (e.g., spot FX, crypto, or select index feeds), fall back cleanly by setting `adj_close = close`.
   * Handle empty responses (0 timestamps) by returning a 0-row typed `tibble` matching the 8-column schema.

4. **Consistent Snake_Case Naming**:
   Use `adj_close` (not `adjclose`, `adjClose`, or `adjusted_close`) across all functional and R6 outputs.

---

## 4. Implementation Steps

1. **Update Parser**: Refactor the internal chart parser function to safely extract `adjclose` and assemble the 8-column tibble.
2. **Harmonize APIs**: Verify that both functional wrappers (`yf_download_prices()`) and R6 methods (`Ticker$get_history()`, `Tickers$get_history()`, `Index$get_history()`) return identical column names and types.
3. **Documentation**: Update roxygen2 docs and run `devtools::document()`.
4. **Unit Tests**: Update and add tests in `tests/testthat/` verifying:
   * Presence and numeric type of `adj_close` in downloaded equity price tibbles.
   * Proper fallback behavior (`adj_close == close`) when `adjclose` is absent.
   * Pipe compatibility with `dplyr::mutate(daily_return = (adj_close / dplyr::lag(adj_close)) - 1)`.

---

## 5. Deliverables & Acceptance Criteria
- [ ] Log created and updated at `specs/fix-parser-adj-close.log.md`.
- [ ] Standardized `adj_close` column returned across all historical price endpoints.
- [ ] `devtools::document()` runs with 0 warnings.
- [ ] `devtools::test()` passes 100% of test suites.
- [ ] `devtools::check(args = "--as-cran")` passes with **0 errors, 0 warnings, 0 notes**.
