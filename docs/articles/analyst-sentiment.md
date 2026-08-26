# Related-Symbol Recommendations and Technical Insights

## Overview

In this guide, you will explore the two sentiment-adjacent surfaces that
Yahoo Finance exposes through `yahoofinancer`: **related-symbol
recommendations** (which securities the market associates most strongly
with a ticker, scored by relevance) and **technical insights** (a
research snapshot combining Trading Central outlooks, key price levels,
a Morningstar-style company scorecard, and an Argus Research rating with
target price).

*(A note on scope: classic sell-side consensus ratings—the
strong-buy/hold/sell vote distribution—are served by Yahoo’s
`quoteSummary` modules, which `yahoofinancer` does not currently wrap.
Everything shown here comes from endpoints the package already
supports.)*

### Required Packages

`# Install required packages if not already installed:`` ``# install.packages(c("dplyr", "ggplot2", "scales", "tidyr"))`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`tidyr`](https://tidyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`purrr`](https://purrr.tidyverse.org/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`

------------------------------------------------------------------------

## 1. Related-Symbol Recommendations

The `recommendations` active binding on a
[`Ticker`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md)
object queries Yahoo’s *recommendations-by-symbol* endpoint and returns
a two-column frame: candidate tickers and their relevance `score`
(roughly 0–1, higher means more strongly associated).

`aapl_obj`` ``<-`` `[`Ticker`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md)`$``new``(``"AAPL"``)`` `` ``related`` ``<-`` ``aapl_obj``$``recommendations`` `` ``related`` ``#> symbol score`` ``#> 1 AMZN 0.20319`` ``#> 2 TSLA 0.19162`` ``#> 3 GOOG 0.17865`` ``#> 4 META 0.17095`` ``#> 5 MSFT 0.15560`

Scores arrive pre-sorted, but sorting explicitly makes intent clear and
survives any upstream ordering change:

`top_related`` ``<-`` ``related`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(`[`desc`](https://dplyr.tidyverse.org/reference/desc.html)`(``score``)``)`` `` ``top_related`` ``#> symbol score`` ``#> 1 AMZN 0.20319`` ``#> 2 TSLA 0.19162`` ``#> ...`

Visualize as a horizontal bar chart so long tick labels stay legible:

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``top_related``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``score``, y ``=`` `[`reorder`](https://rdrr.io/r/stats/reorder.factor.html)`(``symbol``, ``score``)``)``)`` ``+`` `` `[`geom_col`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``fill ``=`` ``"#1f77b4"``, width ``=`` ``0.65``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Securities Most Associated with AAPL"``,`` `` subtitle ``=`` ``"Yahoo Finance related-symbol relevance scores"``,`` `` x ``=`` ``"Relevance score"``,`` `` y ``=`` ``NULL``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``panel.grid.major.y ``=`` `[`element_blank`](https://ggplot2.tidyverse.org/reference/element.html)`(``)``)`

------------------------------------------------------------------------

## 2. The Technical Insights Snapshot

`technical_insights` returns a nested list aggregating several research
providers. It helps to pull the fields you care about into small tibbles
before analyzing them. First, key technical levels from Trading Central:

`ins`` ``<-`` ``aapl_obj``$``technical_insights`` `` ``levels_tbl`` ``<-`` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` level ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Support"``, ``"Resistance"``, ``"Stop loss"``)``,`` `` price ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`` `` ``ins``$``instrumentInfo``$``keyTechnicals``$``support``,`` `` ``ins``$``instrumentInfo``$``keyTechnicals``$``resistance``,`` `` ``ins``$``instrumentInfo``$``keyTechnicals``$``stopLoss`` `` ``)`` ``)`` `` ``levels_tbl`` ``#> # A tibble: 3 × 2`` ``#> level price`` ``#> <chr> <dbl>`` ``#> 1 Support 417.`` ``#> 2 Resistance 507.`` ``#> 3 Stop loss 397.`

Next, the short-, intermediate-, and long-term outlooks, each scored on
Trading Central’s evidence scale:

`te`` ``<-`` ``ins``$``instrumentInfo``$``technicalEvents`` `` ``outlooks_tbl`` ``<-`` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` horizon ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Short term"``, ``"Intermediate term"``, ``"Long term"``)``,`` `` direction ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``te``$``shortTermOutlook``$``direction``,`` `` ``te``$``intermediateTermOutlook``$``direction``,`` `` ``te``$``longTermOutlook``$``direction``)``,`` `` score ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``te``$``shortTermOutlook``$``score``,`` `` ``te``$``intermediateTermOutlook``$``score``,`` `` ``te``$``longTermOutlook``$``score``)``,`` `` description ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``te``$``shortTermOutlook``$``scoreDescription``,`` `` ``te``$``intermediateTermOutlook``$``scoreDescription``,`` `` ``te``$``longTermOutlook``$``scoreDescription``)`` ``)`` `` ``outlooks_tbl`` ``#> # A tibble: 3 × 4`` ``#> horizon direction score description`` ``#> <chr> <chr> <dbl> <chr>`` ``#> 1 Short term Bullish 3 Strong Bullish Evidence`` ``#> 2 Intermediate term Bullish 3 Strong Bullish Evidence`` ``#> 3 Long term Bearish 1 Weak Bearish Evidence`

The valuation block summarizes where price sits relative to fair value:

`ins``$``instrumentInfo``$``valuation``$``description`` ``#> [1] "Near Fair Value"`` `` ``ins``$``instrumentInfo``$``valuation``$``discount`` ``#> [1] "8%"`

------------------------------------------------------------------------

## 3. Company Scorecard vs. Sector

The `companySnapshot` block rates the firm on six dimensions (0–1),
alongside the sector median for comparison. Pivot to long form and chart
both scopes side by side:

`snap`` ``<-`` ``ins``$``companySnapshot`` `` ``snapshot_tbl`` ``<-`` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` dimension ``=`` `[`names`](https://rdrr.io/r/base/names.html)`(``snap``$``company``)``,`` `` Company ``=`` `[`unlist`](https://rdrr.io/r/base/unlist.html)`(``snap``$``company``)``,`` `` Sector ``=`` `[`unlist`](https://rdrr.io/r/base/unlist.html)`(``snap``$``sector``)`` ``)`` `` ``snapshot_long`` ``<-`` ``snapshot_tbl`` ``|>`` `` `[`pivot_longer`](https://tidyr.tidyverse.org/reference/pivot_longer.html)`(``cols ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``Company``, ``Sector``)``,`` `` names_to ``=`` ``"scope"``,`` `` values_to ``=`` ``"score"``)`` `` ``snapshot_long`` ``#> # A tibble: 12 × 3`` ``#> dimension scope score`` ``#> <chr> <chr> <dbl>`` ``#> 1 innovativeness Company 0.977`` ``#> 2 innovativeness Sector 0.5`` ``#> 3 hiring Company 0.966`` ``#> 4 hiring Sector 0.5`` ``#> # i 8 more rows`

[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``snapshot_long``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``score``, y ``=`` `[`reorder`](https://rdrr.io/r/stats/reorder.factor.html)`(``dimension``, ``score``)``)``)`` ``+`` `` `[`geom_point`](https://ggplot2.tidyverse.org/reference/geom_point.html)`(`[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``color ``=`` ``scope``, size ``=`` ``scope``)``, position ``=`` `[`position_dodge`](https://ggplot2.tidyverse.org/reference/position_dodge.html)`(``width ``=`` ``0.5``)``)`` ``+`` `` `[`scale_color_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)`(``values ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Company"`` ``=`` ``"#1f77b4"``, ``"Sector"`` ``=`` ``"#9aa5ad"``)``)`` ``+`` `` `[`scale_size_manual`](https://ggplot2.tidyverse.org/reference/scale_manual.html)`(``values ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Company"`` ``=`` ``3.4``, ``"Sector"`` ``=`` ``2.4``)``, guide ``=`` ``"none"``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``, limits ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``0``, ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Company Scorecard vs. Sector Median"``,`` `` subtitle ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``"Sector:"``, ``snap``$``sectorInfo``)``,`` `` x ``=`` ``"Score"``,`` `` y ``=`` ``NULL``,`` `` color ``=`` ``NULL``,`` `` caption ``=`` ``"Source: Yahoo Finance insights via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``panel.grid.major.y ``=`` `[`element_blank`](https://ggplot2.tidyverse.org/reference/element.html)`(``)``,`` `` legend.position ``=`` ``"top"``)`

------------------------------------------------------------------------

## 4. Research Rating and Target Price

The `recommendation` block carries a provider, categorical rating, and
12-month target price—a compact sentiment triple worth logging alongside
your own models:

`call_tbl`` ``<-`` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` provider ``=`` ``ins``$``recommendation``$``provider``,`` `` rating ``=`` ``ins``$``recommendation``$``rating``,`` `` target_price ``=`` ``ins``$``recommendation``$``targetPrice`` ``)`` `` ``call_tbl`` ``#> # A tibble: 1 × 3`` ``#> provider rating target_price`` ``#> <chr> <chr> <dbl>`` ``#> 1 Argus Research BUY 620`

Recent research report headlines are also embedded under `reports`,
useful for quick qualitative context:

[`head`](https://rdrr.io/r/utils/head.html)`(`[`map_chr`](https://purrr.tidyverse.org/reference/map.html)`(``ins``$``reports``, ``"title"``)``, n ``=`` ``3``)`` ``#> [1] "Last week featured another monumental run for the stock market, as the major indices recaptured ..."`` ``#> [2] "Daily - Vickers Top Buyers & Sellers for 03/10/2026"`` ``#> ...`

------------------------------------------------------------------------

## 5. Comparing Related Symbols Across a Watchlist

For several symbols at once, the
[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md)
class fans out over all of them in one call. Because each source ticker
contributes its own five candidates, the combined frame uses
`recommended_symbol` for the candidates while `symbol` identifies the
source:

`watchlist`` ``<-`` `[`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md)`$``new``(`[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOG"``)``)`` `` ``related_all`` ``<-`` ``watchlist``$``recommendations`` ``|>`` `` `[`as_tibble`](https://tibble.tidyverse.org/reference/as_tibble.html)`(``)`` `` ``related_all`` ``#> # A tibble: 15 x 3`` ``#> symbol recommended_symbol score`` ``#> <chr> <chr> <dbl>`` ``#> 1 AAPL AMZN 0.203`` ``#> 2 AAPL TSLA 0.192`` ``#> 3 AAPL GOOG 0.179`` ``#> 4 MSFT AAPL 0.212`` ``#> 5 MSFT ORCL 0.187`` ``#> # i 10 more rows`

Keep the top candidate per source ticker, sorting inside groups:

`best_per_source`` ``<-`` ``related_all`` ``|>`` `` `[`group_by`](https://dplyr.tidyverse.org/reference/group_by.html)`(``symbol``)`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(`[`desc`](https://dplyr.tidyverse.org/reference/desc.html)`(``score``)``, .by_group ``=`` ``TRUE``)`` ``|>`` `` `[`slice_head`](https://dplyr.tidyverse.org/reference/slice.html)`(``n ``=`` ``1``)`` ``|>`` `` `[`ungroup`](https://dplyr.tidyverse.org/reference/group_by.html)`(``)`` `` ``best_per_source`` ``#> # A tibble: 3 x 3`` ``#> symbol recommended_symbol score`` ``#> <chr> <chr> <dbl>`` ``#> 1 AAPL AMZN 0.203`` ``#> 2 MSFT AAPL 0.212`` ``#> 3 GOOG META 0.196`

------------------------------------------------------------------------

## 6. Minimal Reproducible Example

Below is the complete, self-contained workflow in a single
copy-pasteable script:

[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`` `` ``# 1. Fetch and plot related-symbol recommendations`` ``aapl_obj`` ``<-`` `[`Ticker`](https://yahoofinancer.rsquaredacademy.com/reference/Ticker-class.md)`$``new``(``"AAPL"``)`` ``top_related`` ``<-`` ``aapl_obj``$``recommendations`` ``|>`` `` `[`arrange`](https://dplyr.tidyverse.org/reference/arrange.html)`(`[`desc`](https://dplyr.tidyverse.org/reference/desc.html)`(``score``)``)`` `` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``top_related``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``score``, y ``=`` `[`reorder`](https://rdrr.io/r/stats/reorder.factor.html)`(``symbol``, ``score``)``)``)`` ``+`` `` `[`geom_col`](https://ggplot2.tidyverse.org/reference/geom_bar.html)`(``fill ``=`` ``"#1f77b4"``, width ``=`` ``0.65``)`` ``+`` `` `[`scale_x_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`percent_format`](https://scales.r-lib.org/reference/percent_format.html)`(``accuracy ``=`` ``1``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` ``"Securities Most Associated with AAPL"``,`` `` subtitle ``=`` ``"Yahoo Finance related-symbol relevance scores"``,`` `` x ``=`` ``"Relevance score"``,`` `` y ``=`` ``NULL``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``panel.grid.major.y ``=`` `[`element_blank`](https://ggplot2.tidyverse.org/reference/element.html)`(``)``)`` `` ``# 2. Extract technical insights and key support/resistance levels`` ``ins`` ``<-`` ``aapl_obj``$``technical_insights`` `` ``levels_tbl`` ``<-`` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` level ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Support"``, ``"Resistance"``, ``"Stop loss"``)``,`` `` price ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(`` `` ``ins``$``instrumentInfo``$``keyTechnicals``$``support``,`` `` ``ins``$``instrumentInfo``$``keyTechnicals``$``resistance``,`` `` ``ins``$``instrumentInfo``$``keyTechnicals``$``stopLoss`` `` ``)`` ``)`` ``levels_tbl`` `` ``# 3. Extract research recommendation and price target`` ``call_tbl`` ``<-`` ``tibble``::`[`tibble`](https://tibble.tidyverse.org/reference/tibble.html)`(`` `` provider ``=`` ``ins``$``recommendation``$``provider``,`` `` rating ``=`` ``ins``$``recommendation``$``rating``,`` `` target_price ``=`` ``ins``$``recommendation``$``targetPrice`` ``)`` ``call_tbl`

------------------------------------------------------------------------

## 7. Summary

In this guide, you learned how to:

1.  **Rank market associations**: Pull related-symbol scores with
    `Ticker$recommendations` and visualize them as ranked bars.
2.  **Unpack research snapshots**: Flatten `technical_insights` into
    tidy tables of key levels, directional outlooks, and valuation
    posture.
3.  **Compare against the sector**: Chart the six-dimension company
    scorecard next to its sector median.
4.  **Log the research call**: Capture provider, rating, and target
    price as structured fields.
5.  **Scale to a watchlist**: Fan out across multiple symbols with
    `Tickers` and rank within groups using `.by_group = TRUE`.

------------------------------------------------------------------------

## 8. Going Further

- **Combine with prices**: Overlay `keyTechnicals` support/resistance on
  a
  [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)
  chart—see
  [`vignette("first-stock-analysis", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/first-stock-analysis.md).
- **Dashboard integration**: These surfaces slot directly into the
  reactive layer built in
  [`vignette("shiny-dashboard", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/shiny-dashboard.md).
- **Failure semantics**: Like every network call in the package, both
  bindings warn and return `invisible(NULL)` when Yahoo is
  unreachable—guard with [`is.null()`](https://rdrr.io/r/base/NULL.html)
  before extracting fields.
- **More recipes**: For drawdown analysis, technical indicators (EMA,
  RSI, MACD), and portfolio modeling, see
  [`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md).
