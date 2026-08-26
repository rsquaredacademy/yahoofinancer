# Fundamental Analysis and Stock Screening

## Overview

Fundamental analysis evaluates a company’s financial health, operational
profitability, balance sheet strength, and market valuation multiples.
In this guide, you will build an end-to-end fundamental analysis and
stock screening workflow using `yahoofinancer`:

1.  **Extract Financial Statements**: Download income statements,
    balance sheets, and cash flow statements across multiple peer
    companies using
    [`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md).
2.  **Compute Core Ratios**: Calculate profitability margins (operating
    margin, net profit margin) and cash generation metrics (free cash
    flow conversion).
3.  **Inspect Valuation Multiples**: Retrieve quarterly valuation ratios
    (P/E, forward P/E, PEG, EV/EBITDA, P/B) with
    `Tickers$valuation_measures`.
4.  **Build a Fundamental Screener**: Combine statement metrics and
    valuation multiples into a tidy scorecard to filter and rank
    candidates.
5.  **Visualize Peer Comparisons**: Compare financial performance and
    valuation multiples using `ggplot2`.

### Required Packages

`# Install required packages if needed:`` ``# install.packages(c("yahoofinancer", "dplyr", "tidyr", "ggplot2", "scales"))`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`tidyr`](https://tidyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`

------------------------------------------------------------------------

## 1. Downloading Financial Statements

The functional helper
[`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)
retrieves tidy financial statements across single or multiple tickers.
Statements are available at `"annual"` (default) or `"quarterly"`
frequencies.

### Income Statement

`peer_tickers`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOG"``)`` `` ``income_df`` ``<-`` `[`yf_get_financials`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)`(`` `` tickers ``=`` ``peer_tickers``,`` `` statement_type ``=`` ``"income"``,`` `` frequency ``=`` ``"annual"`` ``)`` `` ``income_df`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``period_type``, ``total_revenue``, ``operating_income``, ``net_income``)`` ``|>`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``n ``=`` ``6``)`` ``#> # A tibble: 6 x 6`` ``#> symbol date period_type total_revenue operating_income net_income`` ``#> <chr> <date> <chr> <dbl> <dbl> <dbl>`` ``#> 1 AAPL 2021-09-25 12M 365817000000 108949000000 94680000000`` ``#> 2 AAPL 2022-09-24 12M 394328000000 119437000000 99803000000`` ``#> 3 AAPL 2023-09-30 12M 383285000000 114301000000 96995000000`` ``#> 4 MSFT 2022-06-30 12M 198270000000 83383000000 72738000000`` ``#> 5 MSFT 2023-06-30 12M 211915000000 88523000000 72361000000`` ``#> 6 MSFT 2024-06-30 12M 245122000000 109433000000 88136000000`

### Cash Flow Statement

Cash flow statements provide visibility into actual cash generated from
operations and free cash flow after capital expenditures:

`cashflow_df`` ``<-`` `[`yf_get_financials`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)`(`` `` tickers ``=`` ``peer_tickers``,`` `` statement_type ``=`` ``"cash-flow"``,`` `` frequency ``=`` ``"annual"`` ``)`` `` ``cashflow_df`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``operating_cash_flow``, ``capital_expenditure``, ``free_cash_flow``)`` ``|>`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``n ``=`` ``6``)`` ``#> # A tibble: 6 x 5`` ``#> symbol date operating_cash_flow capital_expenditure free_cash_flow`` ``#> <chr> <date> <dbl> <dbl> <dbl>`` ``#> 1 AAPL 2021-09-25 104038000000 -11085000000 92953000000`` ``#> 2 AAPL 2022-09-24 122151000000 -10708000000 111443000000`` ``#> 3 AAPL 2023-09-30 110543000000 -10959000000 99584000000`` ``#> 4 MSFT 2022-06-30 89035000000 -23886000000 65149000000`` ``#> 5 MSFT 2023-06-30 87582000000 -28107000000 59475000000`` ``#> 6 MSFT 2024-06-30 118548000000 -44477000000 74071000000`

### Balance Sheet

Balance sheets expose liquidity and solvency positions including working
capital, cash reserves, and debt levels:

`balance_df`` ``<-`` `[`yf_get_financials`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)`(`` `` tickers ``=`` ``peer_tickers``,`` `` statement_type ``=`` ``"balance-sheet"``,`` `` frequency ``=`` ``"annual"`` ``)`` `` ``balance_df`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``total_assets``, ``total_stockholder_equity``, ``working_capital``, ``total_debt``)`` ``|>`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``n ``=`` ``6``)`

------------------------------------------------------------------------

## 2. Computing Profitability & Solvency Ratios

By joining the statement tables, we can compute standardized performance
indicators:

- **Operating Margin**:
  $`\text{Operating Income} / \text{Total Revenue}`$
- **Net Margin**: $`\text{Net Income} / \text{Total Revenue}`$
- **Free Cash Flow Conversion**:
  $`\text{Free Cash Flow} / \text{Operating Cash Flow}`$

`fundamentals`` ``<-`` ``income_df`` ``|>`` `` `[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(``cashflow_df``, by ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"symbol"``, ``"date"``, ``"period_type"``)``)`` ``|>`` `` `[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(``balance_df``, by ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"symbol"``, ``"date"``, ``"period_type"``)``)`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``date``, .by_group ``=`` ``TRUE``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` operating_margin ``=`` ``operating_income`` ``/`` ``total_revenue``,`` `` net_margin ``=`` ``net_income`` ``/`` ``total_revenue``,`` `` fcf_conversion ``=`` ``free_cash_flow`` ``/`` ``operating_cash_flow``,`` `` debt_to_equity ``=`` ``total_debt`` ``/`` ``total_stockholder_equity`` `` ``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` `` ``# View the most recent period for each peer`` ``latest_fundamentals`` ``<-`` ``fundamentals`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``total_revenue``, ``operating_margin``, ``net_margin``, ``fcf_conversion``, ``debt_to_equity``)`` `` ``latest_fundamentals`

------------------------------------------------------------------------

## 3. Valuation Measures Across Peers

Valuation multiples allow comparing market pricing against underlying
fundamentals. Using the `Tickers` class, we retrieve quarterly valuation
measures across the peer group:

`stocks`` ``<-`` `[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md)`$``new``(``peer_tickers``)`` ``val_measures`` ``<-`` ``stocks``$``valuation_measures`` `` ``val_measures`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``market_cap``, ``pe_ratio``, ``forward_pe_ratio``, ``peg_ratio``, ``enterprise_value_ebitda_ratio``)`` ``#> # A tibble: 3 x 7`` ``#> symbol date market_cap pe_ratio forward_pe_ratio peg_ratio enterprise_value_ebitda_ratio`` ``#> <chr> <date> <dbl> <dbl> <dbl> <dbl> <dbl>`` ``#> 1 AAPL 2024-06-30 3.45e12 33.2 28.5 2.10 24.2`` ``#> 2 GOOG 2024-06-30 2.25e12 25.4 21.8 1.45 17.8`` ``#> 3 MSFT 2024-06-30 3.30e12 36.1 30.2 2.35 25.6`

------------------------------------------------------------------------

## 4. Multi-Factor Stock Screening Scorecard

We combine the latest operational margins with current valuation
multiples to create a screening scorecard:

`# Extract latest valuation metrics`` ``latest_valuation`` ``<-`` ``val_measures`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``pe_ratio``, ``forward_pe_ratio``, ``peg_ratio``, ``enterprise_value_ebitda_ratio``)`` `` ``# Combine fundamentals and valuation`` ``screener_table`` ``<-`` ``latest_fundamentals`` ``|>`` `` `[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(``latest_valuation``, by ``=`` ``"symbol"``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` ``# Screening criteria flags`` `` pass_margin ``=`` ``operating_margin`` ``>=`` ``0.25``,`` `` pass_fcf ``=`` ``fcf_conversion`` ``>=`` ``0.70``,`` `` pass_peg ``=`` ``peg_ratio`` ``<`` ``2.5``,`` `` pass_valuation ``=`` ``forward_pe_ratio`` ``<`` ``35``,`` `` screen_passed ``=`` ``pass_margin`` ``&`` ``pass_fcf`` ``&`` ``pass_peg`` ``&`` ``pass_valuation`` `` ``)`` `` ``screener_table`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``operating_margin``, ``fcf_conversion``, ``forward_pe_ratio``, ``peg_ratio``, ``screen_passed``)`

------------------------------------------------------------------------

## 5. Visualizing Peer Comparisons

### Operating Margin Trends

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``fundamentals``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``date``, y ``=`` ``operating_margin``, color ``=`` ``symbol``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``linewidth ``=`` ``1.1``)`` ``+`` `` `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(``size ``=`` ``2.5``)`` ``+`` `` `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`scale_x_date`](https://ggplot2.tidyverse.org/reference/scale_date.html)`(``date_labels ``=`` ``"%Y"``, date_breaks ``=`` ``"1 year"``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Annual Operating Margin Comparison"``,`` `` subtitle ``=`` ``"Operating income as a percentage of total revenue"``,`` `` x ``=`` ``"Fiscal Year"``,`` `` y ``=`` ``"Operating Margin"``,`` `` color ``=`` ``"Company"``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`

### Valuation vs. Operating Profitability

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``screener_table``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``operating_margin``, y ``=`` ``enterprise_value_ebitda_ratio``, label ``=`` ``symbol``)``)`` ``+`` `` `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``color ``=`` ``symbol``)``, size ``=`` ``4``)`` ``+`` `` `[`geom_text`](https://ggplot2.tidyverse.org/reference/geom_text.html)`(``vjust ``=`` ``-``1``, fontface ``=`` ``"bold"``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"EV / EBITDA Multiple vs. Operating Margin"``,`` `` subtitle ``=`` ``"Evaluating valuation premium relative to operating efficiency"``,`` `` x ``=`` ``"Operating Margin"``,`` `` y ``=`` ``"Enterprise Value / EBITDA Multiple"``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"none"``)`

------------------------------------------------------------------------

## 6. Minimal Reproducible Example

Below is the complete, self-contained fundamental screening script:

[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`` `` ``# 1. Define peer universe`` ``tickers`` ``<-`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOG"``)`` `` ``# 2. Fetch income statement and cash flow statements`` ``income_df`` ``<-`` `[`yf_get_financials`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)`(``tickers``, statement_type ``=`` ``"income"``, frequency ``=`` ``"annual"``)`` ``cashflow_df`` ``<-`` `[`yf_get_financials`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md)`(``tickers``, statement_type ``=`` ``"cash-flow"``, frequency ``=`` ``"annual"``)`` `` ``# 3. Retrieve quarterly valuation measures`` ``stocks`` ``<-`` `[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md)`$``new``(``tickers``)`` ``val_measures`` ``<-`` ``stocks``$``valuation_measures`` `` ``# 4. Join and calculate key metrics`` ``latest_income`` ``<-`` ``income_df`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``operating_margin ``=`` ``operating_income`` ``/`` ``total_revenue``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``date``, ``total_revenue``, ``operating_margin``)`` `` ``latest_cf`` ``<-`` ``cashflow_df`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``fcf_conversion ``=`` ``free_cash_flow`` ``/`` ``operating_cash_flow``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``fcf_conversion``)`` `` ``latest_val`` ``<-`` ``val_measures`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` ``|>`` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``symbol``, ``pe_ratio``, ``forward_pe_ratio``, ``peg_ratio``, ``enterprise_value_ebitda_ratio``)`` `` ``screener_summary`` ``<-`` ``latest_income`` ``|>`` `` `[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(``latest_cf``, by ``=`` ``"symbol"``)`` ``|>`` `` `[`left_join`](https://dplyr.tidyverse.org/reference/mutate-joins.html)`(``latest_val``, by ``=`` ``"symbol"``)`` `` ``# 5. Display screener table`` `[`print`](https://rdrr.io/r/base/print.html)`(``screener_summary``)`

------------------------------------------------------------------------

## 7. Summary

In this guide, you learned how to:

1.  **Retrieve Structured Statements**: Access income, balance sheet,
    and cash flow data with
    [`yf_get_financials()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_financials.md).
2.  **Compute Standardized Metrics**: Derive operating margins, net
    margins, and free cash flow conversion.
3.  **Extract Valuation Multiples**: Query multi-stock valuation ratios
    with `Tickers$valuation_measures`.
4.  **Screen & Compare Stocks**: Build custom screening rules combining
    profitability and market valuation.

------------------------------------------------------------------------

## 8. Going Further

- **Quarterly Trend Analysis**: Switch to `frequency = "quarterly"` to
  spot inflection points in revenue and margin trends earlier in the
  fiscal year.
- **Combine with Technicals**: Pair fundamental screening with technical
  indicator snapshots via `Ticker$technical_insights`.
- **Historical Price Context**: Use
  [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)
  to chart stock price performance against earnings and fundamental
  milestones.
- **More recipes**: See
  [`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md)
  for 15 additional recipes spanning portfolios, currency conversion,
  and technical analysis.
