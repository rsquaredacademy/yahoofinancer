# Get Index Quotes

Retrieves current quotes and summary statistics for a given index
symbol.

## Usage

``` r
yf_get_index_quotes(index_symbol)
```

## Arguments

- index_symbol:

  Character string of the index symbol (e.g., "^GSPC").

## Value

A \`tibble\` containing the index quote data.

## Examples

``` r
# \donttest{
yf_get_index_quotes("^GSPC")
#> # A tibble: 1 × 8
#>   symbol date                 open  high   low close adj_close    volume
#>   <chr>  <dttm>              <dbl> <dbl> <dbl> <dbl>     <dbl>     <dbl>
#> 1 ^GSPC  2026-08-18 15:59:34 7700. 7714. 7694. 7702.     7702. 943928194
# }
```
