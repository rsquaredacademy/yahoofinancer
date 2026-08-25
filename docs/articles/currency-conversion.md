# Currency Conversion and Forex Data

## Overview

In this guide you will learn how to discover which currencies Yahoo
Finance supports and how to fetch current and historical exchange rates
between any two of them. You will then combine two currency pairs
(GBP/USD and EUR/USD) into a single normalized comparison chart with
`ggplot2`. These workflows are unique to `yahoofinancer` — no other R
package wraps Yahoo Finance’s currency endpoints — and the entire guide
runs in under five minutes.

### Required Packages

`# Install required packages if not already installed:`` ``# install.packages(c("yahoofinancer", "dplyr", "ggplot2"))`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`

## 1. Discovering Supported Currencies

Before converting anything, it helps to know what Yahoo Finance offers.
The
[`get_currencies()`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md)
helper returns the full catalogue of supported currencies — no arguments
required.

`currencies`` ``<-`` `[`get_currencies`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md)`(``)`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``currencies``)`` ``#> short_name long_name symbol local_long_name`` ``#> 1 USD US Dollar USD US Dollar`` ``#> 2 EUR Euro EUR Euro`` ``#> 3 GBP Pound Sterling GBP Pound Sterling`` ``#> 4 JPY Japanese Yen JPY Japanese Yen`` ``#> 5 CHF Swiss Franc CHF Swiss Franc`` ``#> 6 AUD Australian Dollar AUD Australian Dollar`

Exchange rates on Yahoo Finance are quoted as **pairs**: to convert from
one currency to another, Yahoo builds the symbol `FROM` + `TO` + `=X`.
For example, British pounds to US dollars becomes `GBPUSD=X`, and euros
to dollars becomes `EURUSD=X`. You rarely need to type these symbols
yourself, though — the
[`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)
helper shown next assembles them for you.

> **Note on Robustness:** Like all `yahoofinancer` downloaders,
> [`get_currencies()`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md)
> returns `invisible(NULL)` instead of erroring when the network or API
> is unavailable. Assign the result and check it isn’t `NULL` before
> continuing.

## 2. Fetching Historical Exchange Rates

[`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)
retrieves current and historical rates between any two supported
currencies. You can request a fixed window with `start` and `end` dates:

`gbp_usd`` ``<-`` `[`currency_converter`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)`(`` `` from ``=`` ``"GBP"``,`` `` to ``=`` ``"USD"``,`` `` start ``=`` ``"2024-01-01"``,`` `` end ``=`` ``"2024-12-31"`` ``)`` `` `[`head`](https://rdrr.io/r/utils/head.html)`(``gbp_usd``)`` ``#> date high low open close volume adj_close`` ``#> 1 2024-01-02 00:00:00 1.2734 1.2577 1.2732 1.2602 0 1.2602`` ``#> 2 2024-01-03 00:00:00 1.2716 1.2595 1.2678 1.2631 0 1.2631`` ``#> 3 2024-01-04 00:00:00 1.2709 1.2602 1.2689 1.2677 0 1.2677`` ``#> 4 2024-01-05 00:00:00 1.2721 1.2614 1.2705 1.2717 0 1.2717`` ``#> 5 2024-01-08 00:00:00 1.2741 1.2698 1.2718 1.2720 0 1.2720`` ``#> 6 2024-01-09 00:00:00 1.2743 1.2688 1.2694 1.2694 0 1.2694`

The result mirrors the package’s price-history schema: a data frame with
`date` (POSIXct), `high`, `low`, `open`, `close`, and `volume` columns,
plus `adj_close` for daily or longer intervals. A few things worth
knowing:

- Instead of explicit dates, you can pass a rolling window via `period`
  (e.g., `period = "1mo"`); valid values range from `"1d"` to `"max"`,
  with `"ytd"` as the default.
- `interval` controls granularity (`"1h"`, `"1d"`, `"5d"`, `"1wk"`,
  `"1mo"`, `"3mo"`; default `"1d"`). Intraday intervals omit
  `adj_close`.
- Forex pairs trade no shares, so `volume` is reported as `0` rather
  than a meaningful quantity.
- [`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)
  is standalone — unlike most of the package, no `Ticker` object is
  needed.

> **Note:** For intraday analysis, remember FX markets close on weekends
> — hourly data will show natural gaps.

## 3. Comparing Two Pairs

The real power comes from comparing pairs side by side. Let’s fetch the
euro against the dollar over the same window, stack both pairs into one
long data frame, and label each row with its pair.

`eur_usd`` ``<-`` `[`currency_converter`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)`(`` `` from ``=`` ``"EUR"``,`` `` to ``=`` ``"USD"``,`` `` start ``=`` ``"2024-01-01"``,`` `` end ``=`` ``"2024-12-31"`` ``)`` `` ``fx`` ``<-`` `[`bind_rows`](https://dplyr.tidyverse.org/reference/bind_rows.html)`(`` `` ``gbp_usd`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``pair ``=`` ``"GBP/USD"``)``,`` `` ``eur_usd`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(``pair ``=`` ``"EUR/USD"``)`` ``)`

The pound trades near \$1.27 while the euro trades near \$1.08, so
plotting raw rates would compare *levels*, not *movement*. As in the
portfolio guide, we normalize each series to 100 at the start of the
period so the lines show percentage change — a like-for-like view of
which currency strengthened against the dollar.

`fx_performance`` ``<-`` ``fx`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(``date``)`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``pair``)`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`mutate`](https://dplyr.tidyverse.org/reference/mutate.html)`(`` `` date ``=`` `[`as.Date`](https://rdrr.io/pkg/zoo/man/yearmon.html)`(``date``)``,`` `` normalized_rate ``=`` ``(``close`` ``/`` ``close``[``1``]``)`` ``*`` ``100`` `` ``)`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` `` ``# Where did each pair end the year?`` ``fx_performance`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``pair``)`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`slice_tail`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` `[`%>%`](https://magrittr.tidyverse.org/reference/pipe.html)` `` `[`select`](https://dplyr.tidyverse.org/reference/select.html)`(``pair``, ``date``, ``close``, ``normalized_rate``)`` ``#> # A tibble: 2 × 4`` ``#> pair date close normalized_rate`` ``#> <chr> <date> <dbl> <dbl>`` ``#> 1 EUR/USD 2024-12-31 1.038 96.2`` ``#> 2 GBP/USD 2024-12-31 1.252 98.6`

*(A normalized value below 100 means the currency weakened against the
dollar over the window; above 100 means it strengthened.)*

## 4. Plotting GBP/USD vs EUR/USD

Because the data is tidy — one row per date per pair — plotting both
series takes a single
[`ggplot()`](https://ggplot2.tidyverse.org/reference/ggplot.html) call.
Map `color` to `pair` and `ggplot2` handles the rest.

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``fx_performance``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``date``, y ``=`` ``normalized_rate``, color ``=`` ``pair``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``linewidth ``=`` ``0.8``)`` ``+`` `` `[`geom_hline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``yintercept ``=`` ``100``, linetype ``=`` ``"dashed"``, color ``=`` ``"grey50"``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Pound vs Euro: Performance Against the US Dollar"``,`` `` subtitle ``=`` ``"Daily closing rates in 2024, normalized to 100 at the start of the year"``,`` `` x ``=`` ``"Date"``,`` `` y ``=`` ``"Normalized Rate (Base = 100)"``,`` `` color ``=`` ``"Pair"`` `` ``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``legend.position ``=`` ``"bottom"``)`

In 2024 both European currencies lost ground against the dollar, but the
chart makes it easy to spot divergences — months where sterling held up
better than the euro, or vice versa. Swap in any other supported
currencies from step 1 (e.g., `"JPY"`, `"INR"`, `"CHF"`) to rerun the
exact same workflow.

You now have a reusable recipe for fetching and visualizing
foreign-exchange data, from quick spot checks to multi-pair comparisons.

## Going Further

Now that you can work with exchange rates, explore related features
`yahoofinancer` offers:

- The normalization technique used here is the same one covered in
  [Comparing a Portfolio of
  Stocks](https://yahoofinancer.rsquaredacademy.com/articles/comparing-portfolios.md).
- To see more practical workflows and advanced charts, browse the
  [yahoofinancer
  Cookbook](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md).
- Working with equities priced outside the US? Check the quoting
  currency of any ticker with the `currency` field of the `Ticker` class
  (e.g., `Ticker$new("RELIANCE.NS")$currency` returns `"INR"`) before
  mixing prices across markets.
- For full argument details and valid parameter values, see the
  documentation pages for
  [`currency_converter()`](https://yahoofinancer.rsquaredacademy.com/reference/currency_converter.md)
  and
  [`get_currencies()`](https://yahoofinancer.rsquaredacademy.com/reference/get_currencies.md).
