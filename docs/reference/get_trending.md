# Trending securities

List of trending securities for specific country.

## Usage

``` r
get_trending(country = "US", count = 10)
```

## Arguments

- country:

  Name of the country.

- count:

  Number of securities.

## Value

Securities trending in the country.

## Examples

``` r
# \donttest{
get_trending()
#>  [1] "XOS"     "BTC-USD" "KLAR"    "HD"      "BIDU"    "AMLX"    "FN"     
#>  [8] "PFSA"    "AIXC"    "META"   
# }
```
