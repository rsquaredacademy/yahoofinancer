# Technical Spec: Milestone 2 — Functional `yf_` API Layer

## Objective
Provide user-facing functional wrapper functions prefixed with `yf_` that accept single tickers or character vectors, handle error boundaries gracefully, and return clean `tibble` objects.

## Target File Structure
- `R/functional_api.R`: Main implementation file for exported `yf_` functions.
- `tests/testthat/test-functional_api.R`: Unit test coverage for functional wrappers.

## Exported Functions & Specifications

### 1. `yf_download_prices(tickers, start = NULL, end = NULL, interval = "1d")`
- **Inputs**: 
  - `tickers`: Character vector of stock symbols.
  - `start`, `end`: Dates or character strings (`YYYY-MM-DD`).
  - `interval`: Granularity string (`"1d"`, `"1wk"`, `"1mo"`).
- **Behavior**:
  - Iterates over `tickers` using `Ticker$new(ticker)$get_history(start, end, interval)`.
  - Appends `symbol` column and relocates it to the first column position.
  - Returns a unified `tibble`.

### 2. `yf_get_market_stats(tickers)`
- **Inputs**: `tickers` (character vector).
- **Behavior**:
  - Extracts key valuation and summary fields (e.g., `regular_market_price`, `fifty_two_week_high`, `fifty_two_week_low`, `regular_market_volume`, `previous_close`, `currency`).
  - Combines results into a single row per ticker in a `tibble`.

### 3. `yf_get_financials(tickers, statement_type = c("income", "balance-sheet", "cash-flow"))`
- **Inputs**: `tickers` (character vector), `statement_type` (single choice string).
- **Behavior**:
  - Validates `statement_type` using `match.arg()`.
  - Calls corresponding `Ticker` financial methods (`get_income_statement()`, `get_balance_sheet()`, `get_cash_flow()`).
  - Binds output into a `tibble` with `symbol` as the leading column.

### 4. `yf_get_index_quotes(index_symbol)`
- **Inputs**: `index_symbol` (character string, e.g., `"^GSPC"`, `"^DJI"`).
- **Behavior**:
  - Instantiates `Index$new(index_symbol)` and fetches current index quotes/summary statistics.

## Resilience & Error Handling Policy
- Wrap individual ticker processing in `tryCatch()`.
- On ticker error/failure: emit a warning (`warning("Failed to fetch data for ticker: ", ticker)`) and return `NULL` / empty row so batch processing continues for remaining tickers.
- Ensure all returned data frames are explicitly converted via `tibble::as_tibble()`.