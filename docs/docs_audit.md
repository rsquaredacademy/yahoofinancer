# Comprehensive API Documentation Audit

## 1. Executive Summary

The documentation for `yahoofinancer` provides a solid baseline but
requires hardening for CRAN compliance, schema precision, and improved
user discoverability. The critical issues include the use of
`\donttest{}` instead of `\dontrun{}` on functions making external
network calls (which risks CRAN check failures), vague `@return` blocks
that do not specify the exact `tibble` column schemas (especially post
`adj_close` standardization), missing API constraint warnings (e.g.,
intraday lookback limits), and an absence of `@family` tags for
cross-referencing. `_pkgdown.yml` is functionally complete but can be
reorganized to improve logical grouping.

## 2. Audit Findings Matrix

| Topic / Function | File | Issue Category | Severity | Summary of Finding |
|:---|:---|:---|:---|:---|
| [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md) | `R/functional_api.R` | Examples | High | Uses `\donttest{}` instead of `\dontrun{}`, risking CRAN test timeouts on network failures. |
| [`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md), [`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md), [`yf_get_index_quotes()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_index_quotes.md) | `R/functional_api.R` | Examples | High | Uses `\donttest{}` instead of `\dontrun{}`. |
| [`get_currencies()`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md), [`get_trending()`](https://yahoofinancer.rsquaredacademy.com/reference/get_trending.md), [`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md) | `R/others.R` | Examples | High | Uses `\donttest{}` instead of `\dontrun{}`. |
| `Index$new()` / `Indice-class` | `R/indice.R` | Examples | High | Example lacks `\dontrun{}` wrapper, which fails offline tests due to validation network call. |
| All Functional APIs | `R/functional_api.R` | Return Values | Med | `@return` describes “a tibble” but does not enumerate the exact column schema (e.g., 8-columns for historical prices). |
| `YahooFinanceBase$get_history()` | `R/base.R` | Return Values | Med | `@return` states `data.frame` instead of `tibble`. |
| [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md), `get_history()` | `R/functional_api.R`, `R/base.R`, `R/tickers.R` | API Constraints | Med | Does not document Yahoo Finance API limits (e.g., 7-day lookback limit for `1m` interval, 60-day for `5m`, rate limits). |
| Parameter Validation | `R/functional_api.R`, `R/base.R` | Parameter Accuracy | Low | Valid choices for `interval` and `period` are not consistently enumerated across functional APIs and R6 classes. |
| Cross-referencing | `R/functional_api.R`, `R/others.R` | Documentation Links | Low | Missing `@family` tags to interlink related functions (e.g., `@family historical data`). |
| `Indice-class` vs `Index` | `R/indice.R` | Naming | Low | The class is exported as `Index` but documented under `@name Indice-class`, which creates a mismatch in the `_pkgdown.yml` reference. |

## 3. File-by-File Recommended Changes

### `R/functional_api.R`

#### Proposed `yf_download_prices()`

``` r

#' Download Historical Prices
#'
#' @description
#' Fetches historical price data for single or multiple tickers. Note that Yahoo Finance 
#' enforces lookback limits on intraday data (e.g., "1m" interval is limited to the last 7 days).
#'
#' @param tickers Character vector of stock symbols (e.g., \code{c("AAPL", "MSFT")}).
#' @param start Date or character string representing the start date (`YYYY-MM-DD`).
#' @param end Date or character string representing the end date (`YYYY-MM-DD`).
#' @param interval Time between data points. Valid values are "1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo".
#' @param period Relative time period for data retrieval. Valid values are "1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max". Defaults to "1y" if both `start` and `period` are NULL.
#'
#' @return A tidy \code{tibble} containing 8 columns: \code{symbol} (character), \code{date} (POSIXct), \code{open} (numeric), \code{high} (numeric), \code{low} (numeric), \code{close} (numeric), \code{adj_close} (numeric), and \code{volume} (numeric). Returns an empty \code{tibble} if retrieval fails.
#'
#' @family historical data
#'
#' @examples
#' \dontrun{
#' yf_download_prices("AAPL", start = "2023-01-01", end = "2023-01-10")
#' yf_download_prices(c("AAPL", "MSFT"), period = "6mo", interval = "1mo")
#' }
#'
#' @export
```

#### Proposed `yf_get_market_stats()`

``` r

#' Get Market Statistics
#'
#' @description
#' Retrieves key valuation and summary fields for given tickers.
#'
#' @param tickers Character vector of stock symbols.
#'
#' @return A \code{tibble} containing: \code{symbol}, \code{regular_market_price}, \code{fifty_two_week_high}, \code{fifty_two_week_low}, \code{regular_market_volume}, \code{previous_close}, and \code{currency}. Returns an empty \code{tibble} on failure.
#'
#' @family market data
#'
#' @examples
#' \dontrun{
#' yf_get_market_stats("AAPL")
#' yf_get_market_stats(c("AAPL", "MSFT"))
#' }
#'
#' @export
```

#### Proposed `yf_get_financials()`

``` r

#' Get Financial Statements
#'
#' @description
#' Retrieves financial statements (income statement, balance sheet, or cash flow) for given tickers.
#'
#' @param tickers Character vector of stock symbols.
#' @param statement_type The type of financial statement to retrieve. One of "income", "balance-sheet", or "cash-flow".
#'
#' @return A \code{tibble} of financial data with \code{symbol} as the first column. Schema depends on the requested statement type.
#'
#' @family fundamental data
#'
#' @examples
#' \dontrun{
#' yf_get_financials("AAPL", statement_type = "income")
#' }
#'
#' @export
```

#### Proposed `yf_get_index_quotes()`

``` r

#' Get Index Quotes
#'
#' @description
#' Retrieves current quotes and summary statistics for a given index symbol.
#'
#' @param index_symbol Character string of the index symbol (e.g., "^GSPC").
#'
#' @return A \code{tibble} containing exactly 8 columns (matching historical prices schema) for the current 1-day quote: \code{symbol}, \code{date}, \code{open}, \code{high}, \code{low}, \code{close}, \code{adj_close}, and \code{volume}.
#'
#' @family market data
#'
#' @examples
#' \dontrun{
#' yf_get_index_quotes("^GSPC")
#' }
#'
#' @export
```

### `R/base.R`

#### Proposed `YahooFinanceBase$get_history()`

``` r
    #' @description
    #' Retrieves historical pricing data. Note that intraday intervals (e.g., "1m") face strict lookback limits on Yahoo Finance.
    #' @param period Length of time. Defaults to \code{'ytd'}. Valid values: "1d", "5d", "1mo", "3mo", "6mo", "1y", "2y", "5y", "10y", "ytd", "max".
    #' @param interval Time between data points. Defaults to \code{'1d'}. Valid values: "1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h", "1d", "5d", "1wk", "1mo", "3mo".
    #' @param start Specific starting date. \code{String} or \code{date} object ("YYYY-MM-DD").
    #' @param end Specific ending date. \code{String} or \code{date} object ("YYYY-MM-DD").
    #' @return A tidy \code{tibble} with exactly 8 columns: \code{symbol}, \code{date}, \code{open}, \code{high}, \code{low}, \code{close}, \code{adj_close}, and \code{volume}.
    get_history = function(period = 'ytd', interval = '1d', start = NULL, end = NULL) {
```

### `R/indice.R`

#### Proposed `Index` Class Docblock

``` r
#' R6 Class Representing an Index
#'
#' @description
#' Base class for getting all data related to indices from Yahoo Finance API.
#'
#' @param symbol Symbol for which data has to be retrieved.
#' @param index Deprecated. Use \code{symbol} instead.
#'
#' @docType class
#' @format An R6 class object
#' @name Index-class
#' @aliases Indice-class
#'
#' @export
Index <- R6::R6Class(
```

*(And replace `\dontrun{}` around the example inside `initialize`
method)*:

``` r

    #' @examples
    #' \dontrun{
    #' nifty_50 <- Index$new('^NSEI')
    #' }
```

### `R/others.R`

#### Apply `\dontrun{}` globally

Update
[`get_currencies()`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md),
[`get_trending()`](https://yahoofinancer.rsquaredacademy.com/reference/get_trending.md),
and
[`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)
to use `\dontrun{}` instead of `\donttest{}`. Ensure `@family` tags are
added (e.g., `@family utility functions`).

``` r

#' @examples
#' \dontrun{
#' get_currencies()
#' }
```

### Proposed `_pkgdown.yml`

``` yaml
url: https://yahoofinancer.rsquaredacademy.com
template:
  bootstrap: 5

authors:
  Aravind Hebbali:
    href: https://www.aravindhebbali.com

templates:
  params:
    bootswatch: cerulean
    ganalytics: UA-57270671-33

navbar:
  title: 'yahoofinancer'
  type: inverse
  left:
    - text: 'Home'
      href: index.html
    - text: 'Cookbook'
      href: articles/cookbook.html
    - text: 'Reference'
      menu:
        - text: 'Functions'
          href: reference/index.html
        - text: 'News'
          href: news/index.html
  right:
    - icon: fa-github
      href: https://github.com/rsquaredacademy/yahoofinancer

articles:
  - title: 'Guides & Cookbooks'
    navbar: ~
    contents:
      - cookbook

home:
  links:
    - text: Our R packages
      href: https://pkgs.rsquaredacademy.com
    - text: Read our blog
      href: https://blog.rsquaredacademy.com
    - text: Our ebooks
      href: https://ebooks.rsquaredacademy.com
    - text: Online courses
      href: https://www.rsquaredacademy.com

reference:
  - title: Object-Oriented Interfaces (R6)
    desc: Main classes to instantiate individual or multiple assets.
    contents:
      - Ticker-class
      - Tickers
      - Index-class
      
  - title: Historical Pricing & Quotes
    desc: Functions to retrieve historical prices and live market quotes.
    contents:
      - yf_download_prices
      - yf_get_index_quotes
      - currency_converter
      
  - title: Fundamental & Market Data
    desc: Retrieve financial statements and fundamental statistics.
    contents:
      - yf_get_financials
      - yf_get_market_stats
      
  - title: Market Overview & Utilities
    desc: Live market snapshots, trending assets, and validations.
    contents:
      - get_market_summary
      - get_trending
      - get_currencies
      - validate
```

## 4. Actionable Implementation Checklist

**Update Roxygen Blocks**: Manually edit `R/functional_api.R`,
`R/others.R`, `R/base.R`, and `R/indice.R` using the proposed snippets.

**Fix `\donttest{}` -\> `\dontrun{}`**: Find and replace all
`\donttest{}` instances with `\dontrun{}` across the codebase to prevent
CRAN check failure on network limits.

**Rebuild Documentation**: Run
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
to regenerate the `man/` `.Rd` files and update the `NAMESPACE`.

**Update Pkgdown Config**: Replace the contents of `_pkgdown.yml` with
the proposed configuration to reorganize the reference structure.

**Test Documentation Site**: Run
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
locally to verify the visual hierarchy and ensure no broken links.

**Verify CRAN Checks**: Run `devtools::check(args = "--as-cran")` to
confirm all examples correctly skip external calls and pass offline
verification.
