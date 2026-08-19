# Get Supported Currencies

Retrieves the list of currencies supported by Yahoo Finance.

## Usage

``` r
get_currencies()
```

## Value

A `data.frame` with 4 columns: `short_name` (character), `long_name`
(character), `symbol` (character), `local_long_name` (character).
Returns `invisible(NULL)` on network failure.

## See also

Other currency:
[`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)

## Examples

``` r
if (FALSE) { # \dontrun{
get_currencies()
} # }
```
