# R6 Class Representing an Index

Base class for getting all data related to indices from Yahoo Finance
API.

## Format

An R6 class object

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

Create a new Index object

#### Usage

    Index$new(symbol = NA, index = NA)

#### Arguments

- `symbol`:

  Symbol

- `index`:

  Deprecated. Use `symbol` instead.

#### Returns

A new \`Index\` object

#### Examples

    nifty_50 <- Index$new('^NSEI')

------------------------------------------------------------------------

### Method `set_index()`

Set a new index.

#### Usage

    Index$set_index(symbol = NA, index = NA)

#### Arguments

- `symbol`:

  New symbol

- `index`:

  Deprecated. Use `symbol` instead.

#### Examples

    indice <- Index$new('^NSEI')
    indice$set_index('^NDX')

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

nifty_50 <- Index$new('^NSEI')

## ------------------------------------------------
## Method `Index$set_index`
## ------------------------------------------------

indice <- Index$new('^NSEI')
indice$set_index('^NDX')
```
