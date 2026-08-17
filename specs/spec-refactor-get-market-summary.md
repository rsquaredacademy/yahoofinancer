# Specification: Refactor `get_market_summary()` (Issue #47)

## 1. Overview & Problem Statement
Currently, `get_market_summary()` returns an unformatted, nested `list` parsed directly from the API response. This breaks standard tidyverse workflows, causing functions like `dplyr::filter()` or `dplyr::select()` to fail with:
`no applicable method for 'filter' applied to an object of class "list"`.

This specification defines the refactoring of `get_market_summary()` to return a standardized, flat `tibble` by default while adding an `as_tibble` parameter to allow users to retrieve the raw nested `list` when needed.

---

## 2. Parameters
* **`as_tibble`**: Logical scalar (default: `TRUE`).
  * `TRUE` (default): Parses and flattens market summary items into a tidy, standardized `tibble`.
  * `FALSE`: Returns the raw nested `list` parsed directly from the Yahoo Finance API response for backward compatibility and deep inspection.

---

## 3. Output Schema (`as_tibble = TRUE`)
Extract and standardize the following columns across all returned market records, coercing types safely and assigning `NA` to missing fields:

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `symbol` | `character` | Ticker or index symbol (e.g., `"^GSPC"`, `"^NSEI"`, `"CL=F"`) |
| `short_name` | `character` | Display name of the security or index (e.g., `"S&P 500"`, `"NIFTY 50"`) |
| `regular_market_price` | `numeric` | Current or last traded regular market price |
| `regular_market_change` | `numeric` | Absolute net price change in the regular session |
| `regular_market_change_percent` | `numeric` | Percentage price change in the regular session |
| `regular_market_previous_close` | `numeric` | Previous regular session closing price |
| `market_state` | `character` | Current market trading status (e.g., `"REGULAR"`, `"CLOSED"`, `"PRE"`, `"POST"`) |
| `exchange` | `character` | Exchange identifier code (e.g., `"SNP"`, `"NSE"`, `"NYM"`) |
| `market_time` | `POSIXct` | Timestamp of the quote converted from UNIX epoch time (UTC) |

---

## 4. Edge Cases & Error Handling
* **Type Validation**: Verify `as_tibble` is a single non-missing logical value (`is.logical(as_tibble) && length(as_tibble) == 1 && !is.na(as_tibble)`). Halt with an informative error via `stop()` if invalid.
* **Missing & Heterogeneous Attributes**: Use safe extractors (e.g., `lapply` / `vapply` with `NULL` fallbacks) so missing fields in specific quote objects (e.g., commodities vs. indices) do not cause row binding to fail.
* **Empty Payload**: If the API returns an empty list or zero results, return a 0-row typed `tibble` with the defined column schema (when `as_tibble = TRUE`) or an empty `list()` (when `as_tibble = FALSE`).
* **Network & Endpoint Failures**: Wrap the HTTP request in error handling to surface clear diagnostic messages upon timeout or rate limiting.

---

## 5. Source Implementation
Update the function definition and documentation in `R/market_summary.R` (or equivalent):

```r
#' @title Get Real-Time Market Summary
#' @description Retrieve live market overview snapshots across global benchmark indices, commodities, currencies, and futures.
#' @param as_tibble Logical; if TRUE (default), returns a tidy tibble. If FALSE, returns the raw nested list.
#' @return A tibble of market quotes (if as_tibble = TRUE) or a nested list (if as_tibble = FALSE).
#' @export
#' @examples
#' \dontrun{
#' # Tidy tibble output (default)
#' market_df <- get_market_summary()
#'
#' # Raw list output
#' market_list <- get_market_summary(as_tibble = FALSE)
#' }
get_market_summary <- function(as_tibble = TRUE) {
  if (!is.logical(as_tibble) || length(as_tibble) != 1 || is.na(as_tibble)) {
    stop("`as_tibble` must be a single logical value (TRUE or FALSE).", call. = FALSE)
  }
  
  # Fetch JSON payload from endpoint
  # If as_tibble is TRUE: extract fields, format types, and return tibble::tibble()
  # If as_tibble is FALSE: return raw parsed list
}
```

---

## 6. Documentation Generation
Regenerate Rd documentation and namespace exports using `devtools`:
```r
devtools::document()
```
Verify that `man/get_market_summary.Rd` reflects the new `@param as_tibble` and updated `@return` description.

---

## 7. Unit Test Suite
Add tests in `tests/testthat/test-market_summary.R` verifying:
* Default invocation `get_market_summary()` returns a `tbl_df` / `data.frame`.
* The returned `tibble` contains all required schema columns with correct data types.
* `get_market_summary(as_tibble = FALSE)` returns a `list`.
* Invalid inputs (e.g., `as_tibble = "yes"`, `as_tibble = 123`, `as_tibble = NA`) raise an informative error.
* Direct pipe compatibility with `dplyr::filter()` and `dplyr::select()`.

---

## 8. Verification Checklist
- [ ] `devtools::document()` runs with no warnings.
- [ ] `devtools::test()` passes all unit tests.
- [ ] `devtools::check(args = "--as-cran")` passes with **0 errors, 0 warnings, 0 notes**.
