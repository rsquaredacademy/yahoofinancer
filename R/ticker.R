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
    # Inherits symbol, initialize, set_symbol, get_history from YahooFinanceBase
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
      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$symbol)
      parsed    <- private$api_request(end_point)
      if (is.null(parsed)) return(NULL)
      parsed$chart$result[[1]]$meta
    }
  )
)
