#' R6 Class Representing a Ticker
#'
#' @description
#' Base class for getting all data related to ticker from Yahoo Finance API.
#'
#' @param symbol Symbol for which data has to be retrieved.
#'
#' @importFrom magrittr %>% use_series extract2 extract
#' @importFrom jsonlite fromJSON
#' @import R6 httr purrr lubridate stringr
#' @docType class
#' @format An R6 class object
#' @name Ticker-class
#'
#' @export
Ticker <- R6::R6Class(

  "Ticker",

  public = list(

    #' @field symbol Symbol for which data is retrieved.
    symbol = NULL,

    #' @description
    #' Create a new Ticker object.
    #' @param symbol Symbol.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' @return A new `Ticker` object
    initialize = function(symbol = NA) {
      if (validate(symbol)) {
        self$symbol <- symbol
      } else {
        message("Not a valid symbol.")
        return(invisible(NULL))
      }

    },

    #' @description
    #' Set a new symbol.
    #' @param symbol New symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$set_symbol('msft')
    set_symbol = function(symbol) {
      if (validate(symbol)) {
        self$symbol <- symbol
      } else {
        message("Not a valid symbol.")
        return(invisible(NULL))
      }
    },

    #' @description
    #' Retrieves historical pricing data.
    #' @param period Length of time. Defaults to \code{'ytd'}. Valid values are:
    #' \itemize{
    #' \item \code{'1d'}
    #' \item \code{'5d'}
    #' \item \code{'1mo'}
    #' \item \code{'3mo'}
    #' \item \code{'6mo'}
    #' \item \code{'1y'}
    #' \item \code{'2y'}
    #' \item \code{'5y'}
    #' \item \code{'10y'}
    #' \item \code{'ytd'}
    #' \item \code{'max'}
    #' }
    #' @param interval Time between data points. Defaults to \code{'1d'}. Valid values are:
    #' \itemize{
    #' \item \code{'1m'}
    #' \item \code{'2m'}
    #' \item \code{'5m'}
    #' \item \code{'15m'}
    #' \item \code{'30m'}
    #' \item \code{'60m'}
    #' \item \code{'90m'}
    #' \item \code{'1h'}
    #' \item \code{'1d'}
    #' \item \code{'5d'}
    #' \item \code{'1wk'}
    #' \item \code{'1mo'}
    #' \item \code{'3mo'}
    #' }
    #' @param start Specific starting date. \code{String} or \code{date} object in \code{yyyy-mm-dd} format.
    #' @param end Specific ending date. \code{String} or \code{date} object in \code{yyyy-mm-dd} format.
    #' @return A \code{data.frame}.
    #' @examples
    #' \donttest{
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_history(start = '2022-07-01', interval = '1d')
    #' aapl$get_history(start = '2022-07-01', end = '2022-07-14', interval = '1d')
    #' aapl$get_history(period = '1mo', interval = '1d')
    #' }
    get_history = function(period = 'ytd', interval = '1d', start = NULL, end = NULL) {

      if (!is.null(start)) {
        start_date <- as.numeric(as.POSIXct(ymd(start, tz = "UTC"), tz = "UTC"))
      }

      if (!is.null(end)) {
        end_date <- as.numeric(as.POSIXct(ymd(end, tz = "UTC"), tz = "UTC"))
      }

      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)

      if (!is.null(start) && !is.null(end)) {
        qlist <- list(period1 = start_date, period2 = end_date, interval = interval)
      } else if (!is.null(start) && is.null(end)) {
        qlist <- list(period1 = start_date, period2 = round(as.numeric(as.POSIXct(now("UTC")))), interval = interval)
      } else {
        qlist <- list(range = period, interval = interval)
      }

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp      <- GET(url, query = qlist)
      parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (http_error(resp)) {

        message(
          cat(
            "Yahoo Finance API request failed", '\n',
            paste('Status:', status_code(resp)), '\n',
            paste('Type:', http_status(resp)$category), '\n',
            paste('Mesage:', parsed$quoteSummary$error$code), '\n',
            paste('Description:', parsed$quoteSummary$error$description, '\n'),
            sep = ''
          )
        )

        return(invisible(NULL))
      } else {

        data <-
          parsed %>%
          use_series(chart) %>%
          use_series(result) %>%
          extract2(1)

        indicators <-
          data %>%
          use_series(indicators) %>%
          use_series(quote) %>%
          extract2(1)

        result <- data.frame(
          date   = as_datetime(unlist(data$timestamp)),
          volume = get_metric(indicators, 'volume'),
          high   = get_metric(indicators, 'high'),
          low    = get_metric(indicators, 'low'),
          open   = get_metric(indicators, 'open'),
          close  = get_metric(indicators, 'close')
        )

        intervals <- c('1d', '5d', '1wk', '1mo', '3mo')

        if (interval %in% intervals) {
          adj_close <-
            data %>%
            use_series(indicators) %>%
            use_series(adjclose) %>%
            extract2(1) %>%
            use_series(adjclose)

          result$adj_close <- adj_close

        }

        return(result)
      }

    }
  ),

  active = list(

    #' @field valuation_measures Retrieves valuation measures for most recent four quarters
    valuation_measures = function() {

      path      <- 'ws/fundamentals-timeseries/v1/finance/timeseries/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)

      measure   <- paste0('quarterly', c('MarketCap', 'EnterpriseValue', 'PeRatio', 'ForwardPeRatio',
                                         'PegRatio', 'PsRatio', 'PbRatio', 'EnterprisesValueRevenueRatio',
                                         'EnterprisesValueEBITDARatio'), collapse = ',')

      qlist <- list(type = measure,
                    period1 = 493590046,
                    period2 = round(as.numeric(now())),
                    corsDomain = private$cors_domain)

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp   <- GET(url, query = qlist)
      parsed <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                         simplifyVector = FALSE)

      if (http_error(resp)) {

        message(
          cat(
            "Yahoo Finance API request failed", '\n',
            paste('Status:', status_code(resp)), '\n',
            paste('Type:', http_status(resp)$category), '\n',
            paste('Mesage:', parsed$quoteSummary$error$code), '\n',
            paste('Description:', parsed$quoteSummary$error$description, '\n'),
            sep = ''
          )
        )

        return(invisible(NULL))
      } else {

        data <-
          parsed %>%
          use_series(timeseries) %>%
          use_series(result)

        data.frame(
          date = date(as_datetime(unlist(data[[1]]$timestamp))),
          enterprise_value = private$extract_valuation(data, 'quarterlyEnterpriseValue'),
          enterprise_value_ebitda_ratio = private$extract_valuation(data, 'quarterlyEnterprisesValueEBITDARatio'),
          enterprise_value_revenue_ratio = private$extract_valuation(data, 'quarterlyEnterprisesValueRevenueRatio'),
          forward_pe_ratio = private$extract_valuation(data, 'quarterlyForwardPeRatio'),
          market_cap = private$extract_valuation(data, 'quarterlyMarketCap'),
          pb_ratio = private$extract_valuation(data, 'quarterlyPbRatio'),
          pe_ratio = private$extract_valuation(data, 'quarterlyPeRatio'),
          peg_ratio = private$extract_valuation(data, 'quarterlyPegRatio'),
          ps_ratio = private$extract_valuation(data, 'quarterlyPsRatio')
        )
      }

    },

    #' @field recommendations Recommended symbols
    recommendations = function() {

      path      <- 'v6/finance/recommendationsbysymbol/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(corsDomain = private$cors_domain)

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp      <- GET(url, query = qlist)
      parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                            simplifyVector = FALSE)

      if (http_error(resp)) {

        message(
          cat(
            "Yahoo Finance API request failed", '\n',
            paste('Status:', status_code(resp)), '\n',
            paste('Type:', http_status(resp)$category), '\n',
            paste('Mesage:', parsed$quoteSummary$error$code), '\n',
            paste('Description:', parsed$quoteSummary$error$description, '\n'),
            sep = ''
          )
        )

        return(invisible(NULL))
      } else {

        data <-
          parsed %>%
          use_series(finance) %>%
          use_series(result) %>%
          extract2(1) %>%
          use_series(recommendedSymbols)

        data.frame(
          symbol = map_chr(data, 'symbol'),
          score = map_dbl(data, 'score')
        )

      }

    },

    #' @field technical_insights Technical indicators for given symbol
    technical_insights = function() {

      path      <- 'ws/insights/v2/finance/insights'
      url       <- modify_url(url = private$base_url, path = path)
      qlist     <- list(symbol = self$symbol, corsDomain = private$cors_domain)

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp      <- GET(url, query = qlist)
      parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                            simplifyVector = FALSE)

      if (http_error(resp)) {

        message(
          cat(
            "Yahoo Finance API request failed", '\n',
            paste('Status:', status_code(resp)), '\n',
            paste('Type:', http_status(resp)$category), '\n',
            paste('Mesage:', parsed$quoteSummary$error$code), '\n',
            paste('Description:', parsed$quoteSummary$error$description, '\n'),
            sep = ''
          )
        )

        return(invisible(NULL))
      } else {

        parsed %>%
          use_series(finance) %>%
          use_series(result)

      }

    },


    #' @field currency Currency 
    currency = function() {
      private$meta_info() %>% use_series(currency)
    },

    #' @field exchange_name Exchange name 
    exchange_name = function() {
      private$meta_info() %>% use_series(exchangeName)
    },

    #' @field full_exchange_name Full exchange name 
    full_exchange_name = function() {
      private$meta_info() %>% use_series(fullExchangeName)
    },

    #' @field first_trade_date First trade date 
    first_trade_date = function() {
      private$meta_info() %>% 
        use_series(firstTradeDate) %>%
          as_datetime()
    },

    #' @field regular_market_time Regular market time
    regular_market_time = function() {
      private$meta_info() %>% 
        use_series(regularMarketTime) %>%
          as_datetime()
    },

    #' @field timezone Time zone 
    timezone = function() {
      private$meta_info() %>% use_series(timezone)
    },

    #' @field exchange_timezone_name Exchange timezone name 
    exchange_timezone_name = function() {
      private$meta_info() %>% use_series(exchangeTimezoneName)
    },

    #' @field regular_market_price Regular market price 
    regular_market_price = function() {
      private$meta_info() %>% use_series(regularMarketPrice)
    },

    #' @field fifty_two_week_high Fifty two week high 
    fifty_two_week_high = function() {
      private$meta_info() %>% use_series(fiftyTwoWeekHigh)
    },
    
    #' @field fifty_two_week_low Fifty two week low
    fifty_two_week_low = function() {
      private$meta_info() %>% use_series(fiftyTwoWeekLow)
    },

    #' @field regular_market_day_high Regular market day high 
    regular_market_day_high = function() {
      private$meta_info() %>% use_series(regularMarketDayHigh)
    },

    #' @field regular_market_day_low Regular market day low
    regular_market_day_low = function() {
      private$meta_info() %>% use_series(regularMarketDayLow)
    },

    #' @field regular_market_volume Regular market volume
    regular_market_volume = function() {
      private$meta_info() %>% use_series(regularMarketVolume)
    },

    #' @field previous_close Previous close 
    previous_close = function() {
      private$meta_info() %>% use_series(previousClose)
    }
    
  ),

  private = list(
    base_url = 'https://query2.finance.yahoo.com',
    path = 'v10/finance/quoteSummary/',
    cors_domain = 'finance.yahoo.com',

    # resp_data = function(symbol, module) {
    #   end_point <- paste0(private$path, symbol)
    #   url       <- modify_url(url = private$base_url, path = end_point)
    #   qlist     <- list(modules = module, corsDomain = private$cors_domain)
    #   resp      <- GET(url, query = qlist)
    #   parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)
    #   list(resp = resp, parsed = parsed)
    # },

    # parse_data = function(parsed) {
    #   parsed %>%
    #     use_series(quoteSummary) %>%
    #     use_series(result) %>%
    #     extract2(1)
    # },

    # display_error = function(resp, parsed) {
    #   cat(
    #     "Yahoo Finance API request failed", '\n',
    #     paste('Status:', status_code(resp)), '\n',
    #     paste('Type:', http_status(resp)$category), '\n',
    #     paste('Mesage:', parsed$quoteSummary$error$code), '\n',
    #     paste('Description:', parsed$quoteSummary$error$description, '\n'),
    #     sep = ''
    #   )
    # },

    # display_data = function(req) {
    #   private$parse_data(req$parsed)
    # },

    snake_case = function(x) {
      paste0('_', tolower(x))
    },

    extract_valuation = function(data, measure) {
      data %>%
        map_if(function(x) measure %in% names(x), measure) %>%
        map_depth(2, 'reportedValue') %>%
        map_depth(2, 'raw') %>%
        unlist()
    },

    meta_info = function() {

      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)


      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp      <- GET(url)
      parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (http_error(resp)) {

        message(
          cat(
            "Yahoo Finance API request failed", '\n',
            paste('Status:', status_code(resp)), '\n',
            paste('Type:', http_status(resp)$category), '\n',
            paste('Mesage:', parsed$quoteSummary$error$code), '\n',
            paste('Description:', parsed$quoteSummary$error$description, '\n'),
            sep = ''
          )
        )

        return(invisible(NULL))
      } else {

        parsed %>%
          use_series(chart) %>%
          use_series(result) %>%
          extract2(1) %>%
          use_series(meta)

      }
    }
  )
)
