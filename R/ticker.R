#' R6 Class Representing a Ticker
#'
#' @description
#' Base class for getting all data related to ticker from Yahoo Finance API.
#'
#' @param symbol Symbol for which data has to be retrieved.
#'
#' @importFrom magrittr %>% use_series extract2 extract
#' @importFrom jsonlite fromJSON
#' @import R6 httr purrr lubridate
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
        stop("Not a valid symbol.", call. = FALSE)
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
        stop("Not a valid symbol.", call. = FALSE)
      }
    },

    #' @description
    #' Retrieves historical pricing data.
    #' @param period Length of time. Defaults to \code{'ytd'}.
    #' @param interval Time between data points. Defaults to \code{'1d'}.
    #' @param start Specific starting date. \code{String} or \code{date} object.
    #' @param end Specific ending date. \code{String} or \code{date} object.
    #' @return A \code{data.frame}.
    get_history = function(period = 'ytd', interval = '1d', start = NULL, end = NULL) {

      if (!is.null(start)) {
        start_dt <- lubridate::ymd(start, tz = "UTC", quiet = TRUE)
        if (is.na(start_dt)) {
          stop("Invalid 'start' date format. Please use 'YYYY-MM-DD'.", call. = FALSE)
        }
        start_date <- as.numeric(as.POSIXct(start_dt, tz = "UTC"))
      }

      if (!is.null(end)) {
        end_dt <- lubridate::ymd(end, tz = "UTC", quiet = TRUE)
        if (is.na(end_dt)) {
          stop("Invalid 'end' date format. Please use 'YYYY-MM-DD'.", call. = FALSE)
        }
        end_date <- as.numeric(as.POSIXct(end_dt, tz = "UTC"))
      }

      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$symbol)
      url       <- httr::modify_url(url = private$base_url, path = end_point)

      if (!is.null(start) && !is.null(end)) {
        qlist <- list(period1 = start_date, period2 = end_date, interval = interval)
      } else if (!is.null(start) && is.null(end)) {
        qlist <- list(period1 = start_date, period2 = floor(as.numeric(Sys.time())), interval = interval)
      } else {
        qlist <- list(range = period, interval = interval)
      }

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp   <- httr::GET(url, query = qlist)
      parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (httr::http_error(resp)) {
        err_desc <- if (!is.null(parsed$chart$error$description)) parsed$chart$error$description else "Unknown Error"
        warning(sprintf("Yahoo Finance API failed [%s]: %s", httr::status_code(resp), err_desc), call. = FALSE)
        return(invisible(NULL))
      }

      data <- parsed$chart$result[[1]]
      if (is.null(data$timestamp)) return(data.frame())

      indicators <- data$indicators$quote[[1]]

      result <- data.frame(
        date   = lubridate::as_datetime(unlist(data$timestamp)),
        volume = get_metric(indicators, 'volume'),
        high   = get_metric(indicators, 'high'),
        low    = get_metric(indicators, 'low'),
        open   = get_metric(indicators, 'open'),
        close  = get_metric(indicators, 'close'),
        stringsAsFactors = FALSE
      )

      if (interval %in% c('1d', '5d', '1wk', '1mo', '3mo')) {
        adj_close <- unlist(data$indicators$adjclose[[1]]$adjclose)
        if (length(adj_close) == nrow(result)) result$adj_close <- adj_close
      }

      return(result)
    }
  ),

  active = list(

    #' @field valuation_measures Retrieves valuation measures
    valuation_measures = function() {
      path      <- 'ws/fundamentals-timeseries/v1/finance/timeseries/'
      end_point <- paste0(path, self$symbol)
      url       <- httr::modify_url(url = private$base_url, path = end_point)

      measure   <- paste0('quarterly', c('MarketCap', 'EnterpriseValue', 'PeRatio', 'ForwardPeRatio',
                                         'PegRatio', 'PsRatio', 'PbRatio', 'EnterprisesValueRevenueRatio',
                                         'EnterprisesValueEBITDARatio'), collapse = ',')

      qlist <- list(type = measure, period1 = 493590046, period2 = floor(as.numeric(Sys.time())),
                    corsDomain = private$cors_domain)

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(invisible(NULL))
      }

      resp   <- httr::GET(url, query = qlist)
      parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (httr::http_error(resp)) {
        warning("Yahoo Finance API request failed.", call. = FALSE)
        return(invisible(NULL))
      }

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

    recommendations = function() {
      path      <- 'v6/finance/recommendationsbysymbol/'
      end_point <- paste0(path, self$symbol)
      url       <- httr::modify_url(url = private$base_url, path = end_point)

      if (!curl::has_internet()) return(invisible(NULL))

      resp   <- httr::GET(url, query = list(corsDomain = private$cors_domain))
      parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (httr::http_error(resp)) return(invisible(NULL))

      data <- parsed$finance$result[[1]]$recommendedSymbols
      if (length(data) == 0) return(data.frame())

      data.frame(
        symbol = vapply(data, function(x) x$symbol, character(1)),
        score = vapply(data, function(x) x$score, numeric(1)),
        stringsAsFactors = FALSE
      )
    },

    technical_insights = function() {
      path  <- 'ws/insights/v2/finance/insights'
      url   <- httr::modify_url(url = private$base_url, path = path)
      qlist <- list(symbol = self$symbol, corsDomain = private$cors_domain)

      if (!curl::has_internet()) return(invisible(NULL))

      resp   <- httr::GET(url, query = qlist)
      parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (httr::http_error(resp)) return(invisible(NULL))
      parsed$finance$result
    },

    currency = function() private$meta_info()$currency,
    exchange_name = function() private$meta_info()$exchangeName,
    full_exchange_name = function() private$meta_info()$fullExchangeName,
    first_trade_date = function() lubridate::as_datetime(private$meta_info()$firstTradeDate),
    regular_market_time = function() lubridate::as_datetime(private$meta_info()$regularMarketTime),
    timezone = function() private$meta_info()$timezone,
    exchange_timezone_name = function() private$meta_info()$exchangeTimezoneName,
    regular_market_price = function() private$meta_info()$regularMarketPrice,
    fifty_two_week_high = function() private$meta_info()$fiftyTwoWeekHigh,
    fifty_two_week_low = function() private$meta_info()$fiftyTwoWeekLow,
    regular_market_day_high = function() private$meta_info()$regularMarketDayHigh,
    regular_market_day_low = function() private$meta_info()$regularMarketDayLow,
    regular_market_volume = function() private$meta_info()$regularMarketVolume,
    previous_close = function() private$meta_info()$previousClose
  ),

  private = list(
    base_url = 'https://query2.finance.yahoo.com',
    cors_domain = 'finance.yahoo.com',

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
      url       <- httr::modify_url(url = private$base_url, path = end_point)

      if (!curl::has_internet()) return(NULL)

      resp   <- httr::GET(url)
      parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (httr::http_error(resp)) return(NULL)
      parsed$chart$result[[1]]$meta
    }
  )
)
