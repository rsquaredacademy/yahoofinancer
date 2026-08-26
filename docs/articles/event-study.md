# Event Study: Earnings Announcements and Price Reactions

## Overview

In this guide, you will run a miniature **event study**: measure how a
stock reacts to its own earnings announcements, after stripping out the
market’s general drift. The workflow is the standard one from the
event-study literature, simplified to the *market-adjusted* model:

1.  Pick the announcement dates (the *events*).
2.  Download price history for the stock **and** a benchmark index
    around each date.
3.  Compute daily returns; the **abnormal return** ($`AR_t`$) is the
    stock’s return minus the benchmark’s return on the same day.
4.  Accumulate $`AR_t`$ across an event window (here, 2 days before to 5
    days after the announcement) to obtain the **cumulative abnormal
    return** (CAR).

*(Note: A full event study would estimate a stock-specific beta over a
pre-event estimation window and test CARs for statistical significance.
The market-adjusted shortcut shown here assumes beta ≈ 1—fine for
exploration and visualization, but treat any inference with care.)*

### Required Packages

`# Install required packages if not already installed:`` ``# install.packages(c("dplyr", "tidyr", "purrr", "ggplot2", "scales"))`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`tidyr`](https://tidyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`

------------------------------------------------------------------------

## 1. Define Events and Fetch Windows

We study three recent Apple earnings announcements. For each, we will
download two calendar weeks on either side—enough slack that the ±2/+5
trading-day window always fits inside the fetched range:

`events`` ``<-`` ``tibble``::`[`tribble`](https://tibble.tidyverse.org/reference/tribble.html)`(`` `` ``~``label``, ``~``event_date``,`` `` ``"FY25 Q4"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2025-10-30"``)``,`` `` ``"FY26 Q1"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-01-29"``)``,`` `` ``"FY26 Q2"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-04-30"``)`` ``)`

*(Note: Announcement dates are public knowledge—check Apple’s investor
relations page for your period of interest and adjust freely.)*

Fetching both symbols in one call keeps the benchmark perfectly aligned
with the stock’s calendar:

`aapl_event`` ``<-`` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(`` `` tickers ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"^GSPC"``)``,`` `` start ``=`` `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-01-15"``)``,`` `` end ``=`` `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-02-12"``)``,`` `` interval ``=`` ``"1d"`` ``)`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``aapl_event``, n ``=`` ``4``)`` ``#> # A tibble: 4 x 8`` ``#> symbol date open high low close adj_close volume`` ``#> <chr> <dttm> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>`` ``#> 1 ^GSPC 2026-01-15 14:30:00 6890. 6920. 6880. 6905. 6905. 4.90e9`` ``#> 2 AAPL 2026-01-15 14:30:00 231. 232. 230. 231. 230. 4.51e7`` ``#> 3 ^GSPC 2026-01-16 14:30:00 6905. 6935. 6899. 6928. 6928. 5.12e9`` ``#> 4 AAPL 2026-01-16 14:30:00 231. 233. 230. 232. 231. 4.13e7`

------------------------------------------------------------------------

## 2. Compute Abnormal Returns

The helper below pivots each window to one row per day with side-by-side
price columns, computes daily returns for both series, aligns every row
to the announcement day (`rel_day` 0), and keeps the event window:

`compute_ar`` ``<-`` ``function``(``label``, ``event_date``)`` ``{`` `` ``raw`` ``<-`` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(`` `` tickers ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"^GSPC"``)``,`` `` start ``=`` ``event_date`` ``-`` ``14``,`` `` end ``=`` ``event_date`` ``+`` ``14``,`` `` interval ``=`` ``"1d"`` `` ``)`` `` `` ``raw`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``symbol ``=`` `[`if_else`](https://dplyr.tidyverse.org/reference/if_else.html)`(``symbol`` ``==`` ``"^GSPC"``, ``"index"``, ``symbol``)``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``date``, ``symbol``, ``close``)`` ``|>`` `` `[`pivot_wider`](https://tidyr.tidyverse.org/reference/pivot_wider.html)`(``names_from ``=`` ``symbol``, values_from ``=`` ``close``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``date``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` ret_stock ``=`` ``AAPL`` ``/`` `[`lag`](https://dplyr.tidyverse.org/reference/lead-lag.html)`(``AAPL``)`` ``-`` ``1``,`` `` ret_mkt ``=`` ``index`` ``/`` `[`lag`](https://dplyr.tidyverse.org/reference/lead-lag.html)`(``index``)`` ``-`` ``1``,`` `` ar ``=`` ``ret_stock`` ``-`` ``ret_mkt`` `` ``)`` ``|>`` `` ``# Locate the first session on/after the announcement (t = 0)`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``rel_day ``=`` `[`row_number`](https://dplyr.tidyverse.org/reference/row_number.html)`(``)`` ``-`` `[`which`](https://rdrr.io/r/base/which.html)`(`[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``date``)`` ``>=`` ``event_date``)``[``1``]``)`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``rel_day`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``-``2``:``5``)`` ``|>`` `` `[`transmute`](https://dplyr.tidyverse.org/reference/transmute.html)`(``label``, ``rel_day``, ``ar``)`` ``}`

Running it for a single event shows the shape of the result—the
announcement reaction lands at `rel_day` 0 or 1 depending on whether the
release came before or after the bell:

`ar_q1`` ``<-`` ``compute_ar``(``"FY26 Q1"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-01-29"``)``)`` `` ``ar_q1`` ``#> # A tibble: 8 x 3`` ``#> label rel_day ar`` ``#> <chr> <int> <dbl>`` ``#> 1 FY26 Q1 -2 -0.0042`` ``#> 2 FY26 Q1 -1 0.0019`` ``#> 3 FY26 Q1 0 0.0031`` ``#> 4 FY26 Q1 1 0.0384`` ``#> 5 FY26 Q1 2 0.0057`` ``#> # i 3 more rows`

------------------------------------------------------------------------

## 3. Daily Abnormal Returns Around One Announcement

A diverging bar chart makes the announcement-day pop obvious:

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``ar_q1``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``rel_day``, y ``=`` ``ar``, fill ``=`` ``ar`` ``>=`` ``0``)``)`` ``+`` `` `[`geom_col`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``width ``=`` ``0.7``, show.legend ``=`` ``FALSE``)`` ``+`` `` `[`scale_fill_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)`(``values ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"#c62828"``, ``"#2e7d32"``)``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``breaks ``=`` ``-``2``:``5``)`` ``+`` `` `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"AAPL Abnormal Returns — FY26 Q1 Earnings"``,`` `` subtitle ``=`` ``"Market-adjusted vs. S&P 500; day 0 = announcement"``,`` `` x ``=`` ``"Trading days relative to announcement"``,`` `` y ``=`` ``"Abnormal return"``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`

------------------------------------------------------------------------

## 4. Average CAR Across All Events

Now run the helper over every event with
[`map2_dfr()`](https://purrr.tidyverse.org/reference/map_dfr.html) and
accumulate: thin lines show each announcement’s CAR path, the thick line
their average:

`car_paths`` ``<-`` `[`map2_dfr`](https://purrr.tidyverse.org/reference/map_dfr.html)`(``events``$``label``, ``events``$``event_date``, ``compute_ar``)`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``label``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``rel_day``, .by_group ``=`` ``TRUE``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``car ``=`` `[`cumsum`](https://rdrr.io/r/base/cumsum.html)`(`[`replace_na`](https://tidyr.tidyverse.org/reference/replace_na.html)`(``ar``, ``0``)``)``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` `` ``avg_car`` ``<-`` ``car_paths`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``rel_day``)`` ``|>`` `` `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``car ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``car``)``, .groups ``=`` ``"drop"``)`

*(Note: `arrange(rel_day, .by_group = TRUE)` sorts within each event so
the running sum never crosses event boundaries;
[`replace_na()`](https://tidyr.tidyverse.org/reference/replace_na.html)
guards the leading `NA` return.)*

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``data ``=`` ``car_paths``,`` `` `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``rel_day``, y ``=`` ``car``, group ``=`` ``label``)``,`` `` color ``=`` ``"#9aa5ad"``, linewidth ``=`` ``0.5``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``data ``=`` ``avg_car``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``rel_day``, y ``=`` ``car``)``,`` `` color ``=`` ``"#1f77b4"``, linewidth ``=`` ``1.2``)`` ``+`` `` `[`geom_vline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``xintercept ``=`` ``0``, linetype ``=`` ``"dashed"``, color ``=`` ``"#555555"``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``breaks ``=`` ``-``2``:``5``)`` ``+`` `` `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Average Cumulative Abnormal Return — AAPL Earnings"``,`` `` subtitle ``=`` ``"Grey: individual announcements; blue: average"``,`` `` x ``=`` ``"Trading days relative to announcement"``,`` `` y ``=`` ``"Cumulative abnormal return"``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`

------------------------------------------------------------------------

## 5. Reading the Results

- **A steep jump at day 0/1** means the announcement surprised the
  market relative to the index; a flat path implies results were priced
  in.
- **Drift after day 1** (continuation) versus **reversal** speaks to
  post-earnings-announcement behavior—compare across many quarters
  before believing either pattern.
- **Caveats**: single-stock CARs conflate firm news with sector news
  (the S&P 500 is an imperfect control); without significance testing,
  treat magnitudes as descriptive only. The cookbook’s
  rolling-correlation recipe
  ([`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md))
  is a natural next step toward proper factor controls.

------------------------------------------------------------------------

## 6. Minimal Reproducible Example

Below is the complete, self-contained workflow in a single
copy-pasteable script:

[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`tidyr`](https://tidyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`` `` ``# 1. Events: three earnings announcements, two weeks of slack each side`` ``events`` ``<-`` ``tibble``::`[`tribble`](https://tibble.tidyverse.org/reference/tribble.html)`(`` `` ``~``label``, ``~``event_date``,`` `` ``"FY25 Q4"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2025-10-30"``)``,`` `` ``"FY26 Q1"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-01-29"``)``,`` `` ``"FY26 Q2"``, `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``"2026-04-30"``)`` ``)`` `` ``# 2. Market-adjusted abnormal returns over [-2, +5]`` ``compute_ar`` ``<-`` ``function``(``label``, ``event_date``)`` ``{`` `` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(`[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"^GSPC"``)``,`` `` start ``=`` ``event_date`` ``-`` ``14``,`` `` end ``=`` ``event_date`` ``+`` ``14``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``symbol ``=`` `[`if_else`](https://dplyr.tidyverse.org/reference/if_else.html)`(``symbol`` ``==`` ``"^GSPC"``, ``"index"``, ``symbol``)``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``date``, ``symbol``, ``close``)`` ``|>`` `` `[`pivot_wider`](https://tidyr.tidyverse.org/reference/pivot_wider.html)`(``names_from ``=`` ``symbol``, values_from ``=`` ``close``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``date``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``ret_stock ``=`` ``AAPL`` ``/`` `[`lag`](https://dplyr.tidyverse.org/reference/lead-lag.html)`(``AAPL``)`` ``-`` ``1``,`` `` ret_mkt ``=`` ``index`` ``/`` `[`lag`](https://dplyr.tidyverse.org/reference/lead-lag.html)`(``index``)`` ``-`` ``1``,`` `` ar ``=`` ``ret_stock`` ``-`` ``ret_mkt``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``rel_day ``=`` `[`row_number`](https://dplyr.tidyverse.org/reference/row_number.html)`(``)`` ``-`` `[`which`](https://rdrr.io/r/base/which.html)`(`[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``date``)`` ``>=`` ``event_date``)``[``1``]``)`` ``|>`` `` `[`filter`](https://dplyr.tidyverse.org/reference/filter.html)`(``rel_day`` `[`%in%`](https://rdrr.io/r/base/match.html)` ``-``2``:``5``)`` ``|>`` `` `[`transmute`](https://dplyr.tidyverse.org/reference/transmute.html)`(``label``, ``rel_day``, ``ar``)`` ``}`` `` ``# 3. Cumulate per event and average across events`` ``avg_car`` ``<-`` `[`map2_dfr`](https://purrr.tidyverse.org/reference/map_dfr.html)`(``events``$``label``, ``events``$``event_date``, ``compute_ar``)`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``label``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``rel_day``, .by_group ``=`` ``TRUE``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``car ``=`` `[`cumsum`](https://rdrr.io/r/base/cumsum.html)`(`[`replace_na`](https://tidyr.tidyverse.org/reference/replace_na.html)`(``ar``, ``0``)``)``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``rel_day``)`` ``|>`` `` `[`summarise`](https://dplyr.tidyverse.org/reference/summarise.html)`(``car ``=`` `[`mean`](https://rdrr.io/r/base/mean.html)`(``car``)``, .groups ``=`` ``"drop"``)`` `` ``# 4. Plot the average CAR path`` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``avg_car``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``rel_day``, y ``=`` ``car``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``color ``=`` ``"#1f77b4"``, linewidth ``=`` ``1.2``)`` ``+`` `` `[`geom_vline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``xintercept ``=`` ``0``, linetype ``=`` ``"dashed"``, color ``=`` ``"#555555"``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``breaks ``=`` ``-``2``:``5``)`` ``+`` `` `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``title ``=`` ``"Average CAR — AAPL Earnings Announcements"``,`` `` x ``=`` ``"Trading days relative to announcement"``,`` `` y ``=`` ``"Cumulative abnormal return"``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`

------------------------------------------------------------------------

## 7. Summary

In this guide, you learned how to:

1.  **Frame events**: Turn announcement dates into bounded download
    windows with `yf_download_prices(start, end)`.
2.  **Align stock and benchmark**: Pivot both series onto a shared
    calendar and difference their returns.
3.  **Localize reactions**: Anchor each session to the announcement via
    `rel_day` and slice the \[-2, +5\] window.
4.  **Accumulate evidence**: Build per-event CAR paths (sorting with
    `.by_group = TRUE`) and average them into a single readable chart.

------------------------------------------------------------------------

## 8. Going Further

- **More events**: Loop over a year of announcements—or screen other
  firms—and facet the CAR plots by ticker with `facet_wrap(~ symbol)`.
- **Intraday precision**: Refetch the announcement week at
  `interval = "60m"` (max 730-day lookback applies) to separate the
  opening-gap reaction from same-day drift.
- **Portfolio context**: Compare event-day volume against typical
  turnover using the OHLCV columns already returned.
- **More recipes**: For drawdown analysis, technical indicators (EMA,
  RSI, MACD, Bollinger Bands), and portfolio performance modeling, see
  [`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md).
