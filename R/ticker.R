#' R6 Class Representing a Ticker
#'
#' @description
#' Class for retrieving all data related to a single ticker from the
#' Yahoo Finance API. Inherits \code{get_history()} from
#' \code{\link{YahooFinanceBase-class}}.
#'
#' @param symbol Symbol for which data has to be retrieved (e.g., \code{"AAPL"}).
#'
#' @importFrom magrittr %>% use_series extract2 extract
#' @importFrom jsonlite fromJSON
#' @import R6 httr2 purrr lubridate
#' @docType class
#' @format An R6 class object
#' @name Ticker-class
#'
#' @family historical data
#'
#' @export
Ticker <- R6::R6Class(

  "Ticker",
  inherit = YahooFinanceBase,

  public = list(
    #' @description
    #' Create a new Ticker object.
    #' @param symbol Symbol (e.g., \code{"AAPL"}).
    initialize = function(symbol = NA) {
      private$cached_meta <- NULL
      super$initialize(symbol)
    },

    #' @description
    #' Set a new symbol and clear cached metadata.
    #' @param symbol New symbol (e.g., \code{"AAPL"}).
    set_symbol = function(symbol) {
      private$cached_meta <- NULL
      super$set_symbol(symbol)
    },

    #' @description
    #' Retrieve income statement data.
    #' @param frequency One of \code{"annual"} or \code{"quarterly"}. Defaults to \code{"annual"}.
    #' @return A \code{\link[tibble]{tibble}} with columns \code{date}, \code{period_type},
    #'   and income statement line items, or \code{invisible(NULL)} on failure.
    get_income_statement = function(frequency = c("annual", "quarterly")) {
      frequency <- match.arg(frequency)
      private$fetch_financial_statement(private$income_statement_codes, frequency)
    },

    #' @description
    #' Retrieve balance sheet data.
    #' @param frequency One of \code{"annual"} or \code{"quarterly"}. Defaults to \code{"annual"}.
    #' @return A \code{\link[tibble]{tibble}} with columns \code{date}, \code{period_type},
    #'   and balance sheet line items, or \code{invisible(NULL)} on failure.
    get_balance_sheet = function(frequency = c("annual", "quarterly")) {
      frequency <- match.arg(frequency)
      private$fetch_financial_statement(private$balance_sheet_codes, frequency)
    },

    #' @description
    #' Retrieve cash flow statement data.
    #' @param frequency One of \code{"annual"} or \code{"quarterly"}. Defaults to \code{"annual"}.
    #' @return A \code{\link[tibble]{tibble}} with columns \code{date}, \code{period_type},
    #'   and cash flow statement line items, or \code{invisible(NULL)} on failure.
    get_cash_flow = function(frequency = c("annual", "quarterly")) {
      frequency <- match.arg(frequency)
      private$fetch_financial_statement(private$cash_flow_codes, frequency)
    }
  ),

  active = list(

    #' @field valuation_measures Retrieves valuation measures
    valuation_measures = function() {
      path      <- 'ws/fundamentals-timeseries/v1/finance/timeseries/'
      end_point <- paste0(path, self$symbol)
      measure   <- paste0('quarterly', c('MarketCap', 'EnterpriseValue', 'PeRatio', 'ForwardPeRatio',
                                         'PegRatio', 'PsRatio', 'PbRatio', 'EnterprisesValueRevenueRatio',
                                         'EnterprisesValueEBITDARatio'), collapse = ',')

      qlist <- list(type = measure, period1 = 493590046, period2 = floor(as.numeric(Sys.time())),
                    corsDomain = private$cors_domain)

      parsed <- private$api_request(end_point, qlist)
      if (is.null(parsed)) return(invisible(NULL))

      data <- parsed$timeseries$result
      if (length(data) == 0) return(NULL)

      data.frame(
        date = lubridate::date(lubridate::as_datetime(unlist(data[[1]]$timestamp))),
        enterprise_value = private$extract_valuation(data, 'quarterlyEnterpriseValue'),
        enterprise_value_ebitda_ratio = private$extract_valuation(data, 'quarterlyEnterprisesValueEBITDARatio'),
        enterprise_value_revenue_ratio = private$extract_valuation(data, 'quarterlyEnterprisesValueRevenueRatio'),
        forward_pe_ratio = private$extract_valuation(data, 'quarterlyForwardPeRatio'),
        market_cap = private$extract_valuation(data, 'quarterlyMarketCap'),
        pb_ratio = private$extract_valuation(data, 'quarterlyPbRatio'),
        pe_ratio = private$extract_valuation(data, 'quarterlyPeRatio'),
        peg_ratio = private$extract_valuation(data, 'quarterlyPegRatio'),
        ps_ratio = private$extract_valuation(data, 'quarterlyPsRatio'),
        stringsAsFactors = FALSE
      )
    },

    #' @field recommendations Related symbols recommended by Yahoo Finance and their scores.
    recommendations = function() {
      path      <- 'v6/finance/recommendationsbysymbol/'
      end_point <- paste0(path, self$symbol)

      parsed <- private$api_request(end_point, list(corsDomain = private$cors_domain))
      if (is.null(parsed)) return(invisible(NULL))

      data <- parsed$finance$result[[1]]$recommendedSymbols
      if (length(data) == 0) return(data.frame())

      data.frame(
        symbol = vapply(data, function(x) x$symbol, character(1)),
        score = vapply(data, function(x) x$score, numeric(1)),
        stringsAsFactors = FALSE
      )
    },

    #' @field technical_insights Technical insights and indicators snapshot.
    technical_insights = function() {
      path  <- 'ws/insights/v2/finance/insights'
      qlist <- list(symbol = self$symbol, corsDomain = private$cors_domain)

      parsed <- private$api_request(path, qlist)
      if (is.null(parsed)) return(invisible(NULL))
      parsed$finance$result
    },

    #' @field currency Currency code for the symbol.
    currency = function() private$meta_info()$currency,

    #' @field exchange_name Short name of the stock exchange.
    exchange_name = function() private$meta_info()$exchangeName,

    #' @field full_exchange_name Full name of the stock exchange.
    full_exchange_name = function() private$meta_info()$fullExchangeName,

    #' @field first_trade_date Timestamp of the first recorded trade.
    first_trade_date = function() {
      val <- private$meta_info()$firstTradeDate
      if (is.null(val)) return(NULL)
      lubridate::as_datetime(val)
    },

    #' @field regular_market_time Timestamp of the last market trade.
    regular_market_time = function() {
      val <- private$meta_info()$regularMarketTime
      if (is.null(val)) return(NULL)
      lubridate::as_datetime(val)
    },

    #' @field timezone Timezone code of the exchange.
    timezone = function() private$meta_info()$timezone,

    #' @field exchange_timezone_name Full timezone name of the exchange.
    exchange_timezone_name = function() private$meta_info()$exchangeTimezoneName,

    #' @field regular_market_price Current regular market price.
    regular_market_price = function() private$meta_info()$regularMarketPrice,

    #' @field fifty_two_week_high 52-week high price.
    fifty_two_week_high = function() private$meta_info()$fiftyTwoWeekHigh,

    #' @field fifty_two_week_low 52-week low price.
    fifty_two_week_low = function() private$meta_info()$fiftyTwoWeekLow,

    #' @field regular_market_day_high Highest price during the current trading session.
    regular_market_day_high = function() private$meta_info()$regularMarketDayHigh,

    #' @field regular_market_day_low Lowest price during the current trading session.
    regular_market_day_low = function() private$meta_info()$regularMarketDayLow,

    #' @field regular_market_volume Current trading volume.
    regular_market_volume = function() private$meta_info()$regularMarketVolume,

    #' @field previous_close Closing price of the previous trading day.
    previous_close = function() private$meta_info()$previousClose
  ),

  private = list(
    cached_meta = NULL,

    income_statement_codes = c(
      "TotalRevenue", "OperatingRevenue", "CostOfRevenue", "GrossProfit",
      "OperatingExpense", "OperatingIncome", "NetNonOperatingInterestIncomeExpense",
      "OtherIncomeExpense", "PretaxIncome", "TaxProvision", "NetIncomeContinuousOperations",
      "NetIncome", "BasicEPS", "DilutedEPS", "BasicAverageShares", "DilutedAverageShares",
      "EBITDA", "EBIT", "NormalizedEBITDA", "NormalizedIncome"
    ),

    balance_sheet_codes = c(
      "TotalAssets", "CurrentAssets", "CashAndCashEquivalents", "OtherShortTermInvestments",
      "Receivables", "Inventory", "NonCurrentAssets", "NetPPE", "GoodwillAndOtherIntangibleAssets",
      "TotalLiabilitiesNetMinorityInterest", "CurrentLiabilities", "PayablesAndAccruedExpenses",
      "CurrentDebt", "NonCurrentLiabilitiesTotal", "LongTermDebt", "TotalStockholderEquity",
      "CommonStock", "RetainedEarnings", "WorkingCapital", "InvestedCapital", "NetDebt", "TotalDebt"
    ),

    cash_flow_codes = c(
      "OperatingCashFlow", "CashFlowFromContinuingOperatingActivities",
      "NetIncomeFromContinuingOperations", "DepreciationAndAmortization",
      "ChangeInWorkingCapital", "ChangeInReceivables", "ChangeInInventory",
      "InvestingCashFlow", "CashFlowFromContinuingInvestingActivities",
      "CapitalExpenditure", "NetPPEPurchaseAndSale", "FinancingCashFlow",
      "CashFlowFromContinuingFinancingActivities", "CommonStockIssuancePayments",
      "CashDividendsPaid", "FreeCashFlow", "EndCashPosition", "BeginningCashPosition"
    ),

    fetch_financial_statement = function(metric_codes, frequency = c("annual", "quarterly")) {
      frequency <- match.arg(frequency)
      full_types <- paste0(frequency, metric_codes)
      type_param <- paste(full_types, collapse = ",")

      path <- paste0("ws/fundamentals-timeseries/v1/finance/timeseries/", self$symbol)
      qlist <- list(
        type = type_param,
        period1 = 493590046,
        period2 = floor(as.numeric(Sys.time())),
        corsDomain = private$cors_domain
      )

      parsed <- private$api_request(path, qlist)
      if (is.null(parsed)) return(invisible(NULL))

      data <- parsed$timeseries$result
      if (is.null(data) || length(data) == 0) return(invisible(NULL))

      private$parse_timeseries_statements(data, metric_codes, frequency)
    },

    parse_timeseries_statements = function(data, metric_codes, frequency) {
      rows <- list()
      for (item in data) {
        meta_type <- if (!is.null(item$meta$type)) item$meta$type[[1]] else setdiff(names(item), "meta")[1]
        if (is.null(meta_type) || !meta_type %in% names(item)) next

        obs_list <- item[[meta_type]]
        if (is.null(obs_list) || length(obs_list) == 0) next

        clean_metric <- sub(paste0("^", frequency), "", meta_type)
        snake_metric <- to_snake_case(clean_metric)

        for (obs in obs_list) {
          if (is.null(obs$asOfDate)) next
          d <- obs$asOfDate
          pt <- if (!is.null(obs$periodType)) obs$periodType else NA_character_
          val <- if (!is.null(obs$reportedValue) && !is.null(obs$reportedValue$raw)) {
            as.numeric(obs$reportedValue$raw)
          } else if (!is.null(obs$reportedValue) && is.numeric(obs$reportedValue)) {
            as.numeric(obs$reportedValue)
          } else {
            NA_real_
          }

          rows[[length(rows) + 1]] <- list(
            date = d,
            period_type = pt,
            metric = snake_metric,
            value = val
          )
        }
      }

      if (length(rows) == 0) return(invisible(NULL))

      dates <- vapply(rows, function(r) r$date, character(1))
      period_types <- vapply(rows, function(r) r$period_type, character(1))
      metrics <- vapply(rows, function(r) r$metric, character(1))
      values <- vapply(rows, function(r) r$value, numeric(1))

      long_df <- data.frame(
        date = as.Date(dates),
        period_type = period_types,
        metric = metrics,
        value = values,
        stringsAsFactors = FALSE
      )

      periods <- unique(long_df[, c("date", "period_type")])
      periods <- periods[order(periods$date), , drop = FALSE]
      row.names(periods) <- NULL

      res <- tibble::tibble(
        date = periods$date,
        period_type = periods$period_type
      )

      expected_snakes <- unique(to_snake_case(metric_codes))
      returned_metrics <- unique(long_df$metric)
      ordered_metrics <- expected_snakes[expected_snakes %in% returned_metrics]
      extra_metrics <- setdiff(returned_metrics, ordered_metrics)
      all_to_add <- c(ordered_metrics, extra_metrics)

      for (m in all_to_add) {
        sub_df <- long_df[long_df$metric == m, ]
        idx <- match(paste(res$date, res$period_type), paste(sub_df$date, sub_df$period_type))
        res[[m]] <- sub_df$value[idx]
      }

      return(res)
    },

    extract_valuation = function(data, measure) {
      if (is.null(data) || length(data) == 0) return(numeric(0))
      res <- data %>%
        purrr::map_if(~measure %in% names(.x), measure) %>%
        purrr::map_depth(2, 'reportedValue') %>%
        purrr::map_depth(2, 'raw') %>%
        unlist()
      if (is.null(res)) return(numeric(0))
      return(res)
    },

    meta_info = function() {
      if (!is.null(private$cached_meta)) {
        return(private$cached_meta)
      }
      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$symbol)
      parsed    <- private$api_request(end_point)
      if (is.null(parsed)) return(NULL)
      private$cached_meta <- parsed$chart$result[[1]]$meta
      private$cached_meta
    }
  )
)
