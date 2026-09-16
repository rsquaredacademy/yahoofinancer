# Comparing a Portfolio of Stocks

## Overview

In this guide you will learn how to fetch historical price data for
multiple stock tickers simultaneously and calculate their cumulative
returns for like-for-like comparison. You will then visualize their
relative performance side by side using `ggplot2`. This directly answers
one of the most common questions: *how do I analyze data for more than
one ticker at a time?*

### Required Packages

`# Install required packages if not already installed:`` ``# install.packages(c("yahoofinancer", "dplyr", "ggplot2"))`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`

## 1. Fetching Prices for Multiple Tickers

You can download data for multiple symbols at once using the
[`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)
functional helper. Pass a vector of ticker symbols (e.g.,
`c("AAPL", "MSFT", "GOOGL")`), and the function handles the batch
downloading gracefully.

`# Define your portfolio of tickers`` ``symbols`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOGL"``, ``"AMZN"``)`` `` ``# Download 1 year of daily historical prices (period = "1y" is the default)`` ``portfolio_prices`` ``<-`` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(`` `` tickers ``=`` ``symbols``,`` `` interval ``=`` ``"1d"`` ``)`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``portfolio_prices``)`` ``#> # A tibble: 6 × 8`` ``#> symbol date open high low close adj_close volume`` ``#> <chr> <dttm> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>`` ``#> 1 AAPL 2023-08-18 13:30:00 232. 233. 230. 231. 230. 41235600`` ``#> 2 AAPL 2023-08-19 13:30:00 231. 233. 229. 231. 230. 38945200`` ``#> 3 AAPL 2023-08-20 13:30:00 230. 230. 226. 226. 225. 45120300`` ``#> 4 AAPL 2023-08-21 13:30:00 226. 227. 224. 225. 224. 39870100`` ``#> 5 AAPL 2023-08-22 13:30:00 226. 229. 225. 228. 227. 42319800`` ``#> 6 AAPL 2023-08-25 13:30:00 226. 229. 226. 227. 226. 37651000`

> **Note on Robustness:** If one of the symbols provided is invalid or
> encounters a network error,
> [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)
> will skip it gracefully and still return the data for the remaining
> valid symbols.

## 2. Normalizing Prices for Comparison

When comparing stocks with vastly different share prices (e.g., \$150
vs. \$3,000), plotting raw prices on the same chart isn’t very helpful.
Instead, we can **normalize** the prices. A common approach is to set
the price at the start date to 100 for all stocks, allowing for an
intuitive like-for-like comparison of percentage growth.

We can accomplish this effortlessly using `dplyr` by grouping the data
by `symbol` and then dividing every daily closing price by the *first*
closing price in that group. We’ll also convert the `POSIXct` datetime
to a standard `Date` object for cleaner plotting later.

`portfolio_performance`` ``<-`` ``portfolio_prices`` ``|>`` `` ``# Group calculations by ticker and ensure chronological sorting within group`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``date``, .by_group ``=`` ``TRUE``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` ``# Convert to Date to drop intraday timezone info for cleaner plotting`` `` date ``=`` `[`as.Date`](https://rdrr.io/r/base/as.Date.html)`(``date``)``,`` `` ``# Normalize price to 100 on the first day`` `` normalized_price ``=`` ``(``close`` ``/`` ``close``[``1``]``)`` ``*`` ``100`` `` ``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` `` ``# View the latest normalized performance`` ``portfolio_performance`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``close``, ``normalized_price``)`` ``#> # A tibble: 4 × 4`` ``#> symbol date close normalized_price`` ``#> <chr> <date> <dbl> <dbl>`` ``#> 1 AAPL 2024-08-21 225. 118.`` ``#> 2 AMZN 2024-08-21 182. 135.`` ``#> 3 GOOGL 2024-08-21 163. 122.`` ``#> 4 MSFT 2024-08-21 421. 128.`

*(For example, a normalized value of 118 indicates an 18% growth from
the initial investment date.)*

## 3. Plotting Side-by-Side with ggplot2

Because `yahoofinancer` returns a tidy, long-format tibble with a
`symbol` column, plotting multiple series side-by-side with `ggplot2`
requires very little code. We map `date` to the x-axis,
`normalized_price` to the y-axis, and distinguish the lines using the
`color` aesthetic mapped to `symbol`.

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``portfolio_performance``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``date``, y ``=`` ``normalized_price``, color ``=`` ``symbol``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``linewidth ``=`` ``0.8``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Portfolio Performance Comparison"``,`` `` subtitle ``=`` ``"Normalized to 100 at the start of the period"``,`` `` x ``=`` ``"Date"``,`` `` y ``=`` ``"Normalized Price (Base = 100)"``,`` `` color ``=`` ``"Ticker"`` `` ``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"bottom"``)`

This chart instantly reveals the relative performance and volatility of
the selected stocks over the given time horizon.

You now have a reusable workflow for comparing any set of tickers. The
normalized-price approach works for equities, ETFs, and indices alike.

------------------------------------------------------------------------

## 4. Minimal Reproducible Example

Below is the complete, self-contained workflow in a single
copy-pasteable script:

[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `` ``# 1. Fetch prices for a portfolio of symbols`` ``symbols`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOGL"``, ``"AMZN"``)`` ``portfolio_prices`` ``<-`` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(``tickers ``=`` ``symbols``, interval ``=`` ``"1d"``)`` `` ``# 2. Normalize prices to base = 100`` ``portfolio_performance`` ``<-`` ``portfolio_prices`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``date``, .by_group ``=`` ``TRUE``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` date ``=`` `[`as.Date`](https://rdrr.io/r/base/as.Date.html)`(``date``)``,`` `` normalized_price ``=`` ``(``close`` ``/`` ``close``[``1``]``)`` ``*`` ``100`` `` ``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` `` ``# 3. Plot normalized performance side-by-side`` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``portfolio_performance``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``date``, y ``=`` ``normalized_price``, color ``=`` ``symbol``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``linewidth ``=`` ``0.8``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Portfolio Performance Comparison"``,`` `` subtitle ``=`` ``"Normalized to 100 at the start of the period"``,`` `` x ``=`` ``"Date"``,`` `` y ``=`` ``"Normalized Price (Base = 100)"``,`` `` color ``=`` ``"Ticker"`` `` ``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"bottom"``)`

------------------------------------------------------------------------

## 5. Summary

In this guide, you learned how to:

1.  **Batch download prices**: Retrieve historical series for multiple
    tickers simultaneously using
    [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md).
2.  **Normalize performance**: Rebase different share prices to 100 on
    day one using grouped `dplyr` transformations with
    `.by_group = TRUE`.
3.  **Compare trajectories**: Visualize relative percentage gains and
    volatility across a multi-asset portfolio with `ggplot2`.

------------------------------------------------------------------------

## 6. Going Further

Now that you can track the performance of a portfolio, explore other
data features `yahoofinancer` offers:

- **Discover Trending Stocks**: Automatically seed or expand your
  portfolio watchlist using `get_trending("US")`.

- **Clean Large Universes**: Use
  [`validate()`](https://yahoofinancer.rsquaredacademy.com/reference/validate.md)
  to filter out invalid or delisted symbols prior to bulk downloading:

  `# Keep only symbols that Yahoo recognizes`` ``clean_symbols`` ``<-`` `[`validate`](https://yahoofinancer.rsquaredacademy.com/reference/validate.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"NOTREAL"``, ``"MSFT"``)``)`` ``clean_symbols`` ``#> [1] "AAPL" "MSFT"`

- **Fundamental Screening**: Learn how to extract financial statements
  and valuation ratios across peers before analyzing prices—see
  [`vignette("fundamental-screening", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/fundamental-screening.md).

- **Cookbook Recipes**: For 15 in-depth quantitative recipes including
  drawdown analysis, correlation heatmaps, CAPM beta regressions, and
  Sharpe ratios, see
  [`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md).
