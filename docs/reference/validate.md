# Symbol validation

Validate symbols before retrieving data. This function checks whether
the provided ticker strings are valid according to the Yahoo Finance
API.

## Usage

``` r
validate(symbol = NULL, index = NA, return_logical = FALSE)
```

## Arguments

- symbol:

  A character vector of one or more ticker strings, index or fund names
  (e.g., `c("AAPL", "MSFT")`).

- index:

  Deprecated. Use `symbol` instead.

- return_logical:

  A logical value indicating whether to return a named logical vector.
  If `FALSE` (default), returns a character vector containing only the
  valid symbols. If `TRUE`, returns a named logical vector indicating
  validation status (`TRUE`/`FALSE`) for each symbol.

## Value

If `return_logical = FALSE` (the default), a character vector of valid
symbols. If `return_logical = TRUE`, a named logical vector indicating
validation status for each symbol.

## Details

Symbol validation

## Examples

``` r
if (FALSE) { # \dontrun{
validate("AAPL")
validate(c("AAPL", "NOTASTOCK", "MSFT"))
validate(c("AAPL", "NOTASTOCK", "MSFT"), return_logical = TRUE)
} # }
```
