# Currency Converter

Retrieve current and historical exchange rates between two currencies
via the Yahoo Finance chart API.

## Usage

``` r
currency_converter(
  from = "EUR",
  to = "USD",
  start = NULL,
  end = NULL,
  period = "ytd",
  interval = "1d"
)
```

## Arguments

- from:

  ISO 4217 three-letter currency code to convert from (e.g., `"EUR"`,
  `"GBP"`). Defaults to `"EUR"`.

- to:

  ISO 4217 three-letter currency code to convert to (e.g., `"USD"`,
  `"JPY"`). Defaults to `"USD"`.

- start:

  Specific starting date. `String` or `Date` object in `"YYYY-MM-DD"`
  format.

- end:

  Specific ending date. `String` or `Date` object in `"YYYY-MM-DD"`
  format.

- period:

  Length of time. Defaults to `'ytd'`. Valid values:

  - `'1d'`

  - `'5d'`

  - `'1mo'`

  - `'3mo'`

  - `'6mo'`

  - `'1y'`

  - `'2y'`

  - `'5y'`

  - `'10y'`

  - `'ytd'`

  - `'max'`

- interval:

  Time between data points. Defaults to `'1d'`. Valid values:

  - `'1h'`

  - `'1d'`

  - `'5d'`

  - `'1wk'`

  - `'1mo'`

  - `'3mo'`

## Value

A `data.frame` with columns: `date` (POSIXct), `high`, `low`, `open`,
`close`, `volume` (all numeric), and conditionally `adj_close` (numeric,
present for daily and longer intervals). Rows with `NA` volume are
excluded. Returns `invisible(NULL)` on network failure.

## See also

Other currency:
[`get_currencies()`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md)

## Examples

``` r
if (FALSE) { # \dontrun{
currency_converter('GBP', 'USD', '2022-07-01', '2022-07-10')
currency_converter('GBP', 'USD', period = '1mo', interval = '1d')
} # }
```
