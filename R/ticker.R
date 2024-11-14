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

    #' @field option_chain Option chain data for all expiration dates for a given symbol
    option_chain = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)

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
          use_series(optionChain) %>%
          use_series(result) %>%
          extract2(1) %>%
          use_series(options)

        calls <-
          data %>%
          map_dfr('calls')

        calls$option_type <- 'call'

        puts <-
          data %>%
          map_dfr('puts')

        puts$option_type <- 'put'

        result <- rbind(calls, puts)
        names(result) <- str_replace_all(names(result), '[A-Z]', private$snake_case)

        result$expiration <- as_datetime(result$expiration)
        result$last_trade_date <- as_datetime(result$last_trade_date)

        col_order <- c('expiration', 'option_type', 'contract_symbol', 'strike', 'currency', 'last_price', 'change', 'percent_change', 'open_interest', 'bid', 'ask', 'contract_size', 'last_trade_date', 'implied_volatility', 'in_the_money', 'volume')

        option_chain <- result[, col_order]
        return(option_chain)
      }

    },

    #' @field option_expiration_dates Option expiration dates
    option_expiration_dates = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)

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
          use_series(optionChain) %>%
          use_series(result) %>%
          extract2(1) %>%
          use_series(expirationDates) %>%
          map_dbl(extract) %>%
          as_datetime() %>%
          date()

      }

    },

    #' @field option_strikes Option strikes
    option_strikes = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)

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
          use_series(optionChain) %>%
          use_series(result) %>%
          extract2(1) %>%
          use_series(strikes) %>%
          map_dbl(extract)

      }

    },

    #' @field quote Get real-time quote information for given symbol
    quote = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)

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
          use_series(optionChain) %>%
          use_series(result) %>%
          extract2(1) %>%
          use_series(quote)

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
    }
  )
)
