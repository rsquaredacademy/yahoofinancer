# Technical Spec: Issue #27 — Migrate Core Network Engine to httr2

## Goal
Migrate internal network requests in `YahooFinanceBase` (`R/base.R`) from `httr` to `httr2`.

## Requirements
1. Update `DESCRIPTION`:
   - Remove `httr` from `Imports:`.
   - Add `httr2 (>= 1.0.0)` to `Imports:`.
2. Refactor `R/base.R` (or base class execution engine):
   - Build requests using `httr2::request(url)` and `httr2::req_url_query()`.
   - Add `httr2::req_retry(max_tries = 4, backoff = function(re_try) 2^re_try)` for automatic backoff on HTTP 429 and 5xx errors.
   - Enforce a 15-second timeout via `httr2::req_timeout(15)`.
   - Execute via `httr2::req_perform()` and parse JSON using `httr2::resp_body_json()`.
3. Constraints:
   - Do NOT modify public signatures or return types for `Ticker` or `Index` classes.
   - Keep all offline tests passing (`R_CHECK_INTERNET_AVAILABILITY=FALSE`).