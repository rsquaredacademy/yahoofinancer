# R6 Class Representing an Index

Class for retrieving data related to market indices from the Yahoo
Finance API. Inherits `get_history()` from
[`YahooFinanceBase-class`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase-class.md).

## Format

An R6 class object

## See also

Other historical data:
[`Ticker-class`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md),
[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md),
[`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md),
[`yf_get_index_quotes()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_index_quotes.md)

## Super class

[`yahoofinancer::YahooFinanceBase`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase-class.md)
-\> `Index`

## Active bindings

- `index`:

  Deprecated. Returns `self$symbol`.

## Methods

### Public methods

- [`Index$new()`](#method-Index-new)

- [`Index$set_index()`](#method-Index-set_index)

- [`Index$clone()`](#method-Index-clone)

Inherited methods

- [`yahoofinancer::YahooFinanceBase$get_history()`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase.html#method-get_history)
- [`yahoofinancer::YahooFinanceBase$set_symbol()`](https://yahoofinancer.rsquaredacademy.com/reference/YahooFinanceBase.html#method-set_symbol)

------------------------------------------------------------------------

### Method `new()`

Create a new Index object.

#### Usage

    Index$new(symbol = NA, index = NA)

#### Arguments

- `symbol`:

  Symbol (e.g., `"^NSEI"`).

- `index`:

  Deprecated. Use `symbol` instead.

#### Returns

A new `Index` object.

#### Examples

    \dontrun{
    nifty_50 <- Index$new('^NSEI')
    }

------------------------------------------------------------------------

### Method `set_index()`

Set a new index symbol.

#### Usage

    Index$set_index(symbol = NA, index = NA)

#### Arguments

- `symbol`:

  New symbol.

- `index`:

  Deprecated. Use `symbol` instead.

#### Examples

    \dontrun{
    indice <- Index$new('^NSEI')
    indice$set_index('^NDX')
    }

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Index$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r

## ------------------------------------------------
## Method `Index$new`
## ------------------------------------------------

if (FALSE) { # \dontrun{
nifty_50 <- Index$new('^NSEI')
} # }

## ------------------------------------------------
## Method `Index$set_index`
## ------------------------------------------------

if (FALSE) { # \dontrun{
indice <- Index$new('^NSEI')
indice$set_index('^NDX')
} # }
```
