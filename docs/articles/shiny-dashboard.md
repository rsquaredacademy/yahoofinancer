# Building a Live Market Dashboard with Shiny

## Overview

In this guide, you will combine `yahoofinancer` with
[Shiny](https://shiny.posit.co/) to build a live market dashboard: a web
application that shows real-time quote cards for any ticker, its
position within the 52-week range, and an interactive price history
chart driven by period and interval selectors. No prior Shiny experience
is required—every reactive concept used here is explained as it appears.

### Required Packages

`# Install required packages if not already installed:`` ``# install.packages(c("yahoofinancer", "shiny", "dplyr", "ggplot2", "scales"))`` `` `[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`shiny`](https://shiny.posit.co/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`

------------------------------------------------------------------------

## 1. Dashboard Anatomy

Every Shiny app has two halves:

| Piece | Role | In this dashboard |
|:---|:---|:---|
| `ui` | Declares layout and widgets | Ticker picker, period/interval selects, quote cards, chart area |
| `server` | Holds the logic that reacts to inputs | Fetches quotes and price history, renders text and plots |

The bridge between them is **reactivity**: when the user changes a
widget, expressions that depend on it re-execute automatically. We will
use [`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
so that network calls to Yahoo Finance fire only when the user presses
the *Refresh* button—polite to both the user and the API.

------------------------------------------------------------------------

## 2. Designing the User Interface

The UI below uses
[`sidebarLayout()`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html):
controls on the left, outputs on the right. Note how named vectors in
`choices` display friendly labels (e.g., *“1 Month”*) while passing
compact API values (`"1mo"`) to
[`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md).

`ui`` ``<-`` `[`fluidPage`](https://rdrr.io/pkg/shiny/man/fluidPage.html)`(`` `` title ``=`` ``"Live Market Dashboard"``,`` `` `[`titlePanel`](https://rdrr.io/pkg/shiny/man/titlePanel.html)`(``"Live Market Dashboard"``)``,`` `` `` `[`sidebarLayout`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html)`(`` `` `[`sidebarPanel`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html)`(`` `` width ``=`` ``3``,`` `` `` `[`selectInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)`(`` `` inputId ``=`` ``"symbol"``,`` `` label ``=`` ``"Ticker"``,`` `` choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOG"``, ``"AMZN"``, ``"NVDA"``, ``"META"``)`` `` ``)``,`` `` `` `[`selectInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)`(`` `` inputId ``=`` ``"period"``,`` `` label ``=`` ``"History length"``,`` `` choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"1 Month"`` ``=`` ``"1mo"``, ``"3 Months"`` ``=`` ``"3mo"``,`` `` ``"6 Months"`` ``=`` ``"6mo"``, ``"1 Year"`` ``=`` ``"1y"``,`` `` ``"2 Years"`` ``=`` ``"2y"``, ``"5 Years"`` ``=`` ``"5y"``)``,`` `` selected ``=`` ``"6mo"`` `` ``)``,`` `` `` `[`selectInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)`(`` `` inputId ``=`` ``"interval"``,`` `` label ``=`` ``"Bar interval"``,`` `` choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Daily"`` ``=`` ``"1d"``, ``"Weekly"`` ``=`` ``"1wk"``, ``"Monthly"`` ``=`` ``"1mo"``)`` `` ``)``,`` `` `` `[`actionButton`](https://rdrr.io/pkg/shiny/man/actionButton.html)`(``"refresh"``, ``"Refresh data"``, class ``=`` ``"btn-primary"``)`` `` ``)``,`` `` `` `[`mainPanel`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html)`(`` `` width ``=`` ``9``,`` `` `` ``# Quote cards row`` `` `[`fluidRow`](https://rdrr.io/pkg/shiny/man/fluidPage.html)`(`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(``4``, `[`wellPanel`](https://rdrr.io/pkg/shiny/man/wellPanel.html)`(`` `` `[`h4`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`textOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"price_card"``)``)``,`` `` `[`p`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`uiOutput`](https://rdrr.io/pkg/shiny/man/htmlOutput.html)`(``"change_card"``)``, style ``=`` ``"margin-bottom: 0;"``)`` `` ``)``)``,`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(``4``, `[`wellPanel`](https://rdrr.io/pkg/shiny/man/wellPanel.html)`(`` `` `[`h4`](https://rstudio.github.io/htmltools/reference/builder.html)`(``"52-Week Range"``)``,`` `` `[`p`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`textOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"range_card"``)``, style ``=`` ``"margin-bottom: 0;"``)`` `` ``)``)``,`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(``4``, `[`wellPanel`](https://rdrr.io/pkg/shiny/man/wellPanel.html)`(`` `` `[`h4`](https://rstudio.github.io/htmltools/reference/builder.html)`(``"Volume"``)``,`` `` `[`p`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`textOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"volume_card"``)``, style ``=`` ``"margin-bottom: 0;"``)`` `` ``)``)`` `` ``)``,`` `` `` ``# Price history chart`` `` `[`plotOutput`](https://rdrr.io/pkg/shiny/man/plotOutput.html)`(``"price_chart"``, height ``=`` ``"360px"``)`` `` ``)`` `` ``)`` ``)`

------------------------------------------------------------------------

## 3. Reactive Data Layer

The server fetches two datasets per refresh:

1.  A one-row snapshot from
    [`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)
    feeding the quote cards.
2.  An OHLCV series from
    [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)
    feeding the chart.

Both are wrapped in `eventReactive(input$refresh, ...)`, so each press
of the button triggers exactly one pair of requests.

`server`` ``<-`` ``function``(``input``, ``output``, ``session``)`` ``{`` `` `` ``stats`` ``<-`` `[`eventReactive`](https://rdrr.io/pkg/shiny/man/observeEvent.html)`(``input``$``refresh``, ``{`` `` `[`yf_get_market_stats`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)`(``input``$``symbol``)`` `` ``}``)`` `` `` ``prices`` ``<-`` `[`eventReactive`](https://rdrr.io/pkg/shiny/man/observeEvent.html)`(``input``$``refresh``, ``{`` `` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(`` `` tickers ``=`` ``input``$``symbol``,`` `` period ``=`` ``input``$``period``,`` `` interval ``=`` ``input``$``interval`` `` ``)`` `` ``}``)`` `` `` ``# ... output renderers added in sections 4 and 5 ...`` ``}`

A snapshot looks like this:

[`yf_get_market_stats`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)`(``"AAPL"``)`` ``#> # A tibble: 1 × 7`` ``#> symbol regular_market_price fifty_two_week_high fifty_two_week_low`` ``#> <chr> <dbl> <dbl> <dbl>`` ``#> 1 AAPL 232. 237. 169.`` ``#> # i 3 more variables: regular_market_volume <dbl>, previous_close <dbl>,`` ``#> # currency <chr>`

*(Note: Values are illustrative; live results reflect the latest
available session.)*

------------------------------------------------------------------------

## 4. Quote Cards

The cards read from the `stats()` reactive. `price_card`, `range_card`,
and `volume_card` use
[`renderText()`](https://rdrr.io/pkg/shiny/man/renderPrint.html), while
`change_card` uses
[`renderUI()`](https://rdrr.io/pkg/shiny/man/renderUI.html) to color the
percentage move green or red based on direction. The range card places
the current price within the 52-week band.

` ``output``$``price_card`` ``<-`` `[`renderText`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s · %s"``, ``stats``(``)``$``symbol``, `[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`(``stats``(``)``$``regular_market_price``)``)`` `` ``}``)`` `` `` ``output``$``change_card`` ``<-`` `[`renderUI`](https://rdrr.io/pkg/shiny/man/renderUI.html)`(``{`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` ``pct`` ``<-`` ``100`` ``*`` ``(``s``$``regular_market_price`` ``-`` ``s``$``previous_close``)`` ``/`` ``s``$``previous_close`` `` ``color`` ``<-`` ``if`` ``(``pct`` ``>=`` ``0``)`` ``"#2e7d32"`` ``else`` ``"#c62828"`` `` ``tags``$``span``(``style ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"color:%s"``, ``color``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%+.2f%% vs previous close"``, ``pct``)``)`` `` ``}``)`` `` `` ``output``$``range_card`` ``<-`` `[`renderText`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` ``pos`` ``<-`` ``100`` ``*`` ``(``s``$``regular_market_price`` ``-`` ``s``$``fifty_two_week_low``)`` ``/`` `` ``(``s``$``fifty_two_week_high`` ``-`` ``s``$``fifty_two_week_low``)`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(`` `` ``"%s — %s\n(%s of 52-week range)"``,`` `` `[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`(``s``$``fifty_two_week_low``)``, `[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`(``s``$``fifty_two_week_high``)``,`` `` `[`percent`](https://scales.r-lib.org/reference/percent_format.html)`(``pos`` ``/`` ``100``, accuracy ``=`` ``1``)`` `` ``)`` `` ``}``)`` `` `` ``output``$``volume_card`` ``<-`` `[`renderText`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` `[`label_number`](https://scales.r-lib.org/reference/label_number.html)`(``scale_cut ``=`` ``scales``::`[`cut_short_scale`](https://scales.r-lib.org/reference/number.html)`(``)``)``(``s``$``regular_market_volume``)`` `` ``}``)`

Two defensive details worth keeping:

- `req(stats())` silently suspends rendering until the first successful
  fetch—no errors flash before data arrives.
- The percentage uses
  [`scales::percent()`](https://scales.r-lib.org/reference/percent_format.html)
  with explicit `accuracy`, so values like `12.34567%` never leak into
  the UI.

------------------------------------------------------------------------

## 5. Price History Chart

The chart plots closing prices over time with dashed reference lines at
the 52-week extremes. Because `date` arrives as a `POSIXct` datetime,
the axis works unchanged for daily, weekly, and monthly bars alike.

` ``output``$``price_chart`` ``<-`` `[`renderPlot`](https://rdrr.io/pkg/shiny/man/renderPlot.html)`(``{`` `` ``df`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``prices``(``)``)`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` `` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``df``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``date``, y ``=`` ``close``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``color ``=`` ``"#1f77b4"``, linewidth ``=`` ``0.9``)`` ``+`` `` `[`geom_hline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``yintercept ``=`` ``s``$``fifty_two_week_high``,`` `` linetype ``=`` ``"dashed"``, color ``=`` ``"#2e7d32"``)`` ``+`` `` `[`geom_hline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``yintercept ``=`` ``s``$``fifty_two_week_low``,`` `` linetype ``=`` ``"dashed"``, color ``=`` ``"#c62828"``)`` ``+`` `` `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`dollar_format`](https://scales.r-lib.org/reference/dollar_format.html)`(``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(`` `` title ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``s``$``symbol``, ``"Price History"``)``,`` `` subtitle ``=`` ``"Dashed lines mark 52-week high and low"``,`` `` x ``=`` ``NULL``,`` `` y ``=`` ``"Price (USD)"``,`` `` caption ``=`` ``"Source: Yahoo Finance via yahoofinancer"`` `` ``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``plot.title ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``face ``=`` ``"bold"``)``)`` `` ``}``)`

------------------------------------------------------------------------

## 6. Minimal Reproducible Example

Here is the complete, self-contained app in a single copy-pasteable
script. Save it as `app.R` and run
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

[`library`](https://rdrr.io/r/base/library.html)`(`[`yahoofinancer`](https://yahoofinancer.rsquaredacademy.com/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`shiny`](https://shiny.posit.co/)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`dplyr`](https://dplyr.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`ggplot2`](https://ggplot2.tidyverse.org)`)`` `[`library`](https://rdrr.io/r/base/library.html)`(`[`scales`](https://scales.r-lib.org)`)`` `` ``ui`` ``<-`` `[`fluidPage`](https://rdrr.io/pkg/shiny/man/fluidPage.html)`(`` `` `[`titlePanel`](https://rdrr.io/pkg/shiny/man/titlePanel.html)`(``"Live Market Dashboard"``)``,`` `` `[`sidebarLayout`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html)`(`` `` `[`sidebarPanel`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html)`(`` `` width ``=`` ``3``,`` `` `[`selectInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)`(``"symbol"``, ``"Ticker"``,`` `` choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"AAPL"``, ``"MSFT"``, ``"GOOG"``, ``"AMZN"``, ``"NVDA"``, ``"META"``)``)``,`` `` `[`selectInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)`(``"period"``, ``"History length"``,`` `` choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"1 Month"`` ``=`` ``"1mo"``, ``"3 Months"`` ``=`` ``"3mo"``,`` `` ``"6 Months"`` ``=`` ``"6mo"``, ``"1 Year"`` ``=`` ``"1y"``,`` `` ``"2 Years"`` ``=`` ``"2y"``, ``"5 Years"`` ``=`` ``"5y"``)``,`` `` selected ``=`` ``"6mo"``)``,`` `` `[`selectInput`](https://rdrr.io/pkg/shiny/man/selectInput.html)`(``"interval"``, ``"Bar interval"``,`` `` choices ``=`` `[`c`](https://rdrr.io/r/base/c.html)`(``"Daily"`` ``=`` ``"1d"``, ``"Weekly"`` ``=`` ``"1wk"``,`` `` ``"Monthly"`` ``=`` ``"1mo"``)``)``,`` `` `[`actionButton`](https://rdrr.io/pkg/shiny/man/actionButton.html)`(``"refresh"``, ``"Refresh data"``, class ``=`` ``"btn-primary"``)`` `` ``)``,`` `` `[`mainPanel`](https://rdrr.io/pkg/shiny/man/sidebarLayout.html)`(`` `` width ``=`` ``9``,`` `` `[`fluidRow`](https://rdrr.io/pkg/shiny/man/fluidPage.html)`(`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(``4``, `[`wellPanel`](https://rdrr.io/pkg/shiny/man/wellPanel.html)`(`` `` `[`h4`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`textOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"price_card"``)``)``,`` `` `[`p`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`uiOutput`](https://rdrr.io/pkg/shiny/man/htmlOutput.html)`(``"change_card"``)``, style ``=`` ``"margin-bottom: 0;"``)`` `` ``)``)``,`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(``4``, `[`wellPanel`](https://rdrr.io/pkg/shiny/man/wellPanel.html)`(`` `` `[`h4`](https://rstudio.github.io/htmltools/reference/builder.html)`(``"52-Week Range"``)``,`` `` `[`p`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`textOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"range_card"``)``, style ``=`` ``"margin-bottom: 0;"``)`` `` ``)``)``,`` `` `[`column`](https://rdrr.io/pkg/shiny/man/column.html)`(``4``, `[`wellPanel`](https://rdrr.io/pkg/shiny/man/wellPanel.html)`(`` `` `[`h4`](https://rstudio.github.io/htmltools/reference/builder.html)`(``"Volume"``)``,`` `` `[`p`](https://rstudio.github.io/htmltools/reference/builder.html)`(`[`textOutput`](https://rdrr.io/pkg/shiny/man/textOutput.html)`(``"volume_card"``)``, style ``=`` ``"margin-bottom: 0;"``)`` `` ``)``)`` `` ``)``,`` `` `[`plotOutput`](https://rdrr.io/pkg/shiny/man/plotOutput.html)`(``"price_chart"``, height ``=`` ``"360px"``)`` `` ``)`` `` ``)`` ``)`` `` ``server`` ``<-`` ``function``(``input``, ``output``, ``session``)`` ``{`` `` ``stats`` ``<-`` `[`eventReactive`](https://rdrr.io/pkg/shiny/man/observeEvent.html)`(``input``$``refresh``, `[`yf_get_market_stats`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)`(``input``$``symbol``)``)`` `` ``prices`` ``<-`` `[`eventReactive`](https://rdrr.io/pkg/shiny/man/observeEvent.html)`(``input``$``refresh``, ``{`` `` `[`yf_download_prices`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)`(``input``$``symbol``, period ``=`` ``input``$``period``,`` `` interval ``=`` ``input``$``interval``)`` `` ``}``)`` `` `` ``output``$``price_card`` ``<-`` `[`renderText`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s · %s"``, ``s``$``symbol``, `[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`(``s``$``regular_market_price``)``)`` `` ``}``)`` `` ``output``$``change_card`` ``<-`` `[`renderUI`](https://rdrr.io/pkg/shiny/man/renderUI.html)`(``{`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` ``pct`` ``<-`` ``100`` ``*`` ``(``s``$``regular_market_price`` ``-`` ``s``$``previous_close``)`` ``/`` ``s``$``previous_close`` `` ``color`` ``<-`` ``if`` ``(``pct`` ``>=`` ``0``)`` ``"#2e7d32"`` ``else`` ``"#c62828"`` `` ``tags``$``span``(``style ``=`` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"color:%s"``, ``color``)``,`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%+.2f%% vs previous close"``, ``pct``)``)`` `` ``}``)`` `` ``output``$``range_card`` ``<-`` `[`renderText`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` ``pos`` ``<-`` ``100`` ``*`` ``(``s``$``regular_market_price`` ``-`` ``s``$``fifty_two_week_low``)`` ``/`` `` ``(``s``$``fifty_two_week_high`` ``-`` ``s``$``fifty_two_week_low``)`` `` `[`sprintf`](https://rdrr.io/r/base/sprintf.html)`(``"%s — %s\n(%s of range)"``,`` `` `[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`(``s``$``fifty_two_week_low``)``,`` `` `[`dollar`](https://scales.r-lib.org/reference/dollar_format.html)`(``s``$``fifty_two_week_high``)``,`` `` `[`percent`](https://scales.r-lib.org/reference/percent_format.html)`(``pos`` ``/`` ``100``, accuracy ``=`` ``1``)``)`` `` ``}``)`` `` ``output``$``volume_card`` ``<-`` `[`renderText`](https://rdrr.io/pkg/shiny/man/renderPrint.html)`(``{`` `` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)``$``regular_market_volume`` ``|>`` `[`label_number`](https://scales.r-lib.org/reference/label_number.html)`(``scale_cut ``=`` `[`cut_short_scale`](https://scales.r-lib.org/reference/number.html)`(``)``)`` `` ``}``)`` `` `` ``output``$``price_chart`` ``<-`` `[`renderPlot`](https://rdrr.io/pkg/shiny/man/renderPlot.html)`(``{`` `` ``df`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``prices``(``)``)`` `` ``s`` ``<-`` `[`req`](https://rdrr.io/pkg/shiny/man/req.html)`(``stats``(``)``)`` `` `[`ggplot`](https://ggplot2.tidyverse.org/reference/ggplot.html)`(``df``, `[`aes`](https://ggplot2.tidyverse.org/reference/aes.html)`(``x ``=`` ``date``, y ``=`` ``close``)``)`` ``+`` `` `[`geom_line`](https://ggplot2.tidyverse.org/reference/geom_path.html)`(``color ``=`` ``"#1f77b4"``, linewidth ``=`` ``0.9``)`` ``+`` `` `[`geom_hline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``yintercept ``=`` ``s``$``fifty_two_week_high``,`` `` linetype ``=`` ``"dashed"``, color ``=`` ``"#2e7d32"``)`` ``+`` `` `[`geom_hline`](https://ggplot2.tidyverse.org/reference/geom_abline.html)`(``yintercept ``=`` ``s``$``fifty_two_week_low``,`` `` linetype ``=`` ``"dashed"``, color ``=`` ``"#c62828"``)`` ``+`` `` `[`scale_y_continuous`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)`(``labels ``=`` `[`dollar_format`](https://scales.r-lib.org/reference/dollar_format.html)`(``)``)`` ``+`` `` `[`labs`](https://ggplot2.tidyverse.org/reference/labs.html)`(``title ``=`` `[`paste`](https://rdrr.io/r/base/paste.html)`(``s``$``symbol``, ``"Price History"``)``, x ``=`` ``NULL``, y ``=`` ``"Price (USD)"``)`` ``+`` `` `[`theme_minimal`](https://ggplot2.tidyverse.org/reference/ggtheme.html)`(``base_size ``=`` ``12``)`` ``+`` `` `[`theme`](https://ggplot2.tidyverse.org/reference/theme.html)`(``plot.title ``=`` `[`element_text`](https://ggplot2.tidyverse.org/reference/element.html)`(``face ``=`` ``"bold"``)``)`` `` ``}``)`` ``}`` `` `[`shinyApp`](https://rdrr.io/pkg/shiny/man/shinyApp.html)`(``ui``, ``server``)`

*(Note: Remember to press **Refresh data** after launching—the app
deliberately makes no network calls until asked.)*

------------------------------------------------------------------------

## 7. Summary

In this guide, you learned how to:

1.  **Structure a Shiny app**: Pair a `fluidPage` UI with a `server`
    function connected by reactive IDs.
2.  **Fetch on demand**: Use
    [`eventReactive()`](https://rdrr.io/pkg/shiny/man/observeEvent.html)
    so Yahoo Finance is queried only when the user requests new data.
3.  **Render live metrics**: Turn
    [`yf_get_market_stats()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_get_market_stats.md)
    snapshots into formatted quote cards with `scales` labeling.
4.  **Chart interactive history**: Drive
    [`yf_download_prices()`](https://yahoofinancer.rsquaredacademy.com/reference/yf_download_prices.md)
    from period/interval widgets and overlay 52-week reference levels.

------------------------------------------------------------------------

## 8. Going Further

- **Auto-refresh**: Add
  `observe({ invalidateLater(60000); shinyjs::click("refresh") })` (with
  the `shinyjs` package) to poll every minute during market hours.
- **Multi-symbol comparison**: Fan out over several tickers at once with
  the
  [`Tickers`](https://yahoofinancer.rsquaredacademy.com/reference/Tickers.md)
  class—`Tickers$new(c("AAPL", "MSFT"))$get_history(period = "6mo")`
  returns one long tibble; sort chronologically inside groups with
  `arrange(date, .by_group = TRUE)` before plotting one line per
  `symbol`.
- **Input validation**: Guard against typos by routing custom tickers
  through
  [`validate()`](https://yahoofinancer.rsquaredacademy.com/reference/validate.md)
  before fetching.
- **More recipes**: For drawdown analysis, technical indicators, and
  portfolio performance modeling, see
  [`vignette("cookbook", package = "yahoofinancer")`](https://yahoofinancer.rsquaredacademy.com/articles/cookbook.md).
