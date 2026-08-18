# Get Real-Time Market Summary

Retrieve live market overview snapshots across global benchmark indices,
commodities, currencies, and futures.

## Usage

``` r
get_market_summary(as_tibble = TRUE)
```

## Arguments

- as_tibble:

  Logical; if TRUE (default), returns a tidy tibble. If FALSE, returns
  the raw nested list.

## Value

A tibble of market quotes (if as_tibble = TRUE) or a nested list (if
as_tibble = FALSE).

## Examples

``` r
if (FALSE) { # \dontrun{
# Tidy tibble output (default)
market_df <- get_market_summary()

# Raw list output
market_list <- get_market_summary(as_tibble = FALSE)
} # }
```
