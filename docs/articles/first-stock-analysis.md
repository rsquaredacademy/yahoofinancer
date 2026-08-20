# Your First Stock Analysis with yahoofinancer

## Overview

In this guide, you will learn how to extract historical stock prices
from Yahoo Finance, understand the returned data structure, compute a
50-day Simple Moving Average (SMA), and produce a publication-ready
price and trend chart using `ggplot2`—with zero prior finance or
algorithmic trading experience required.

### Required Packages

``` r

# Install required packages if not already installed:
# install.packages(c("yahoofinancer", "dplyr", "ggplot2", "zoo", "scales"))

library(yahoofinancer)
library(dplyr)
library(ggplot2)
library(zoo)
library(scales)
```

------------------------------------------------------------------------

## 1. Download Historical Stock Prices

To download historical stock data, use the functional helper
[`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md).
By default, specifying a ticker and a relative time period (e.g., `"1y"`
for 1 year) pulls daily Open, High, Low, Close, Adjusted Close, and
Volume (OHLCV) records.

``` r

# Fetch 1 year of daily historical data for Apple Inc. (AAPL)
aapl <- yf_download_prices(
  tickers  = "AAPL",
  period   = "1y",
  interval = "1d"
)

head(aapl)
#> # A tibble: 6 × 8
#>   symbol date                 open  high   low close adj_close   volume
#>   <chr>  <dttm>              <dbl> <dbl> <dbl> <dbl>     <dbl>    <dbl>
#> 1 AAPL   2025-08-18 13:30:00  232.  233.  230.  231.      230. 41235600
#> 2 AAPL   2025-08-19 13:30:00  231.  233.  229.  231.      230. 38945200
#> 3 AAPL   2025-08-20 13:30:00  230.  230.  226.  226.      225. 45120300
#> 4 AAPL   2025-08-21 13:30:00  226.  227.  224.  225.      224. 39870100
#> 5 AAPL   2025-08-22 13:30:00  226.  229.  225.  228.      227. 42319800
#> 6 AAPL   2025-08-25 13:30:00  226.  229.  226.  227.      226. 37651000
```

*(Note: Output timestamps and values are illustrative; your query
results will reflect the latest available market trading sessions.)*

### Understanding the Data Columns

| Column | Type | Description |
|:---|:---|:---|
| `symbol` | `character` | Ticker symbol representing the asset (e.g., `"AAPL"`). |
| `date` | `POSIXct` / `Date` | Timestamp representing the trading session. |
| `open` | `numeric` | Price at the opening bell. |
| `high` | `numeric` | Highest price reached during the session. |
| `low` | `numeric` | Lowest price reached during the session. |
| `close` | `numeric` | Final settlement price at the closing bell. |
| `adj_close` | `numeric` | Price adjusted for stock splits and dividend distributions. |
| `volume` | `numeric` | Total number of shares traded during the session. |

------------------------------------------------------------------------

## 2. Compute a 50-Day Moving Average

A **Simple Moving Average (SMA)** calculates the average closing price
over a sliding window of $`N`$ days. The 50-day moving average (SMA-50)
is one of the most widely followed trend indicators:

- When the price is **above** the 50-day SMA, the asset is considered to
  be in an intermediate uptrend.
- When the price is **below** the 50-day SMA, it indicates intermediate
  downward pressure.

We can compute this rolling metric easily using `dplyr` and
[`zoo::rollmean()`](https://rdrr.io/pkg/zoo/man/rollmean.html):

``` r

aapl_trend <- aapl %>%
  arrange(date) %>%
  mutate(
    sma_50 = rollmean(close, k = 50, fill = NA, align = "right")
  )

tail(aapl_trend)
#> # A tibble: 6 × 9
#>   symbol date                 open  high   low close adj_close   volume sma_50
#>   <chr>  <dttm>              <dbl> <dbl> <dbl> <dbl>     <dbl>    <dbl>  <dbl>
#> 1 AAPL   2026-08-11 13:30:00  224.  226.  223.  225.      225. 40124300   221.
#> 2 AAPL   2026-08-12 13:30:00  225.  228.  224.  227.      227. 43105200   221.
#> 3 AAPL   2026-08-13 13:30:00  227.  230.  226.  229.      229. 48721100   222.
#> 4 AAPL   2026-08-14 13:30:00  229.  231.  228.  230.      230. 42390800   222.
#> 5 AAPL   2026-08-15 13:30:00  230.  232.  229.  231.      231. 39912000   223.
#> 6 AAPL   2026-08-18 13:30:00  231.  233.  230.  232.      232. 41050000   223.
```

*(Note: The first 49 rows will contain `NA` for `sma_50` until a full
50-day window has accumulated.)*

------------------------------------------------------------------------

## 3. Visualize Price and Trend with ggplot2

With `ggplot2`, we can plot the daily closing price alongside the
smoothed 50-day moving average:

``` r

# Convert POSIXct timestamp to Date for clean daily axis scaling
ggplot(aapl_trend, aes(x = as.Date(date))) +
  # Closing price line
  geom_line(aes(y = close, color = "Closing Price"), linewidth = 0.85) +
  # 50-Day Moving Average line
  geom_line(aes(y = sma_50, color = "50-Day SMA"), linewidth = 1.05, na.rm = TRUE) +
  # Custom colors and formatting
  scale_color_manual(
    name = "Series",
    values = c("Closing Price" = "#1f77b4", "50-Day SMA" = "#e6550d")
  ) +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %Y") +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Apple Inc. (AAPL) — 1-Year Price History",
    subtitle = "Daily Closing Price with 50-Day Simple Moving Average (SMA-50)",
    x = "Date",
    y = "Price (USD)",
    caption = "Source: Yahoo Finance via yahoofinancer"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )
```

------------------------------------------------------------------------

## 4. Minimal Reproducible Example

Below is the complete, self-contained workflow in a single
copy-pasteable script:

``` r

library(yahoofinancer)
library(dplyr)
library(ggplot2)
library(zoo)
library(scales)

# 1. Download 1 year of daily historical prices
aapl <- yf_download_prices("AAPL", period = "1y", interval = "1d")

# 2. Compute 50-day Simple Moving Average
aapl_analyzed <- aapl %>%
  arrange(date) %>%
  mutate(sma_50 = rollmean(close, k = 50, fill = NA, align = "right"))

# 3. Plot price chart with SMA overlay
ggplot(aapl_analyzed, aes(x = as.Date(date))) +
  geom_line(aes(y = close, color = "Closing Price"), linewidth = 0.85) +
  geom_line(aes(y = sma_50, color = "50-Day SMA"), linewidth = 1.05, na.rm = TRUE) +
  scale_color_manual(
    name = "Series",
    values = c("Closing Price" = "#1f77b4", "50-Day SMA" = "#e6550d")
  ) +
  scale_x_date(date_breaks = "2 months", date_labels = "%b %Y") +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    title = "Apple Inc. (AAPL) — 1-Year Price History",
    subtitle = "Daily Closing Price with 50-Day Simple Moving Average (SMA-50)",
    x = "Date",
    y = "Price (USD)",
    caption = "Source: Yahoo Finance via yahoofinancer"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  )
```

------------------------------------------------------------------------

## 5. Summary

In this guide, you learned how to:

1.  **Download market data**: Query clean OHLCV time series with
    [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md).
2.  **Compute indicators**: Use `dplyr` and
    [`zoo::rollmean()`](https://rdrr.io/pkg/zoo/man/rollmean.html) to
    compute rolling metrics.
3.  **Visualize trends**: Build publication-ready charts comparing price
    action and trend indicators using `ggplot2`.

------------------------------------------------------------------------

## 6. Going Further

Now that you have fetched your first dataset and built a chart, here are
several next steps and related features to explore:

- **Custom Date Ranges**: Specify exact date boundaries instead of
  relative periods:

  ``` r

  aapl_custom <- yf_download_prices("AAPL", start = "2024-01-01", end = "2024-12-31")
  ```

- **Different Frequencies**: Query weekly (`interval = "1wk"`) or
  monthly (`interval = "1mo"`) bars for multi-year trend analysis.

- **Global Equities & Indices**: Fetch international securities using
  standard exchange suffixes (e.g., `"RELIANCE.NS"` for NSE India or
  `"AZN.L"` for London) or market indices (e.g., `Index$new("^GSPC")`
  for the S&P 500).

- **Object-Oriented R6 Interface**: For stateful workflows, market
  metadata, and fundamental valuation metrics, use the
  [`Ticker`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md)
  class:

  ``` r

  aapl_obj <- Ticker$new("AAPL")

  # Inspect security metadata and valuation measures
  aapl_obj$currency
  aapl_obj$valuation_measures

  # Historical prices via R6
  aapl_obj$get_history(period = "1y", interval = "1d")
  ```

- **Cookbook Recipes**: For 15 in-depth quantitative recipes including
  drawdown analysis, technical indicators (EMA, RSI, MACD, Bollinger
  Bands), and portfolio performance modeling, see
  [`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md).
