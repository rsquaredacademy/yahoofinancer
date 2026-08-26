#' R6 Class Representing a Yahoo Finance Base Object
#'
#' @description
#' Base class for Ticker and Index classes.
#'
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON
#' @import R6 httr2 purrr lubridate
#' @docType class
#' @format An R6 class object
#' @name YahooFinanceBase-class
#'
#' @keywords internal
YahooFinanceBase <- R6::R6Class(

  "YahooFinanceBase",

  public = list(

    #' @field symbol Symbol for which data is retrieved.
    symbol = NULL,

    #' @description
    #' Create a new YahooFinanceBase object.
    #' @param symbol Symbol.
    initialize = function(symbol = NA) {
      if (isTRUE(unname(validate(symbol, return_logical = TRUE)[1]))) {
        self$symbol <- symbol
      } else {
        stop("Not a valid symbol.", call. = FALSE)
      }
    },

    #' @description
    #' Set a new symbol.
    #' @param symbol New symbol
    set_symbol = function(symbol) {
      if (isTRUE(unname(validate(symbol, return_logical = TRUE)[1]))) {
        self$symbol <- symbol
      } else {
        stop("Not a valid symbol.", call. = FALSE)
      }
    },

    #' @description
    #' Retrieves historical pricing data from the Yahoo Finance chart API.
    #'
    #' **Intraday lookback limits** (imposed by Yahoo Finance):
    #' \itemize{
    #'   \item \code{"1m"}: max 7 days
    #'   \item \code{"5m"}, \code{"15m"}, \code{"30m"}: max 60 days
    #'   \item \code{"1h"}: max 730 days
    #' }
    #'
    #' @param period Length of time. Defaults to \code{'ytd'}. Valid values:
    #' \code{"1d"}, \code{"5d"}, \code{"1mo"}, \code{"3mo"}, \code{"6mo"},
    #' \code{"1y"}, \code{"2y"}, \code{"5y"}, \code{"10y"}, \code{"ytd"}, \code{"max"}.
    #' Ignored when \code{start} is provided.
    #' @param interval Time between data points. Defaults to \code{'1d'}. Valid values:
    #' \code{"1m"}, \code{"2m"}, \code{"5m"}, \code{"15m"}, \code{"30m"},
    #' \code{"60m"}, \code{"90m"}, \code{"1h"}, \code{"1d"}, \code{"5d"},
    #' \code{"1wk"}, \code{"1mo"}, \code{"3mo"}.
    #' @param start Specific starting date. \code{String} or \code{Date} object
    #'   in \code{"YYYY-MM-DD"} format.
    #' @param end Specific ending date. \code{String} or \code{Date} object
    #'   in \code{"YYYY-MM-DD"} format. Defaults to today when \code{start} is
    #'   provided but \code{end} is \code{NULL}.
    #' @return A \code{\link[tibble]{tibble}} with 8 columns:
    #' \describe{
    #'   \item{\code{symbol}}{Character. Ticker symbol.}
    #'   \item{\code{date}}{POSIXct. Timestamp of the data point (UTC).}
    #'   \item{\code{open}}{Numeric. Opening price.}
    #'   \item{\code{high}}{Numeric. Period high.}
    #'   \item{\code{low}}{Numeric. Period low.}
    #'   \item{\code{close}}{Numeric. Closing price.}
    #'   \item{\code{adj_close}}{Numeric. Split- and dividend-adjusted close.
    #'     Falls back to \code{close} when the API omits adjusted data.}
    #'   \item{\code{volume}}{Numeric. Trading volume.}
    #' }
    #' Returns \code{invisible(NULL)} on network failure or invalid symbol.
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
        if (!is.null(start) && start_dt > end_dt) {
          stop("'start' date must be before or equal to 'end' date.", call. = FALSE)
        }
      }

      if (!is.null(end) && is.null(start)) {
        warning("'end' was provided without 'start'. Ignoring 'end' and using 'period'.", call. = FALSE)
        end <- NULL
      }

      intraday_intervals <- c("1m", "2m", "5m", "15m", "30m", "60m", "90m", "1h")
      if (interval %in% intraday_intervals) {
        max_days <- if (interval == "1m") {
          7
        } else if (interval %in% c("2m", "5m", "15m", "30m", "60m", "90m")) {
          60
        } else {
          730
        }

        if (!is.null(start)) {
          days_diff <- as.numeric(difftime(Sys.Date(), lubridate::as_date(start_dt), units = "days"))
          if (days_diff > max_days) {
            stop(sprintf("Interval '%s' is limited to a maximum lookback of %d days.", interval, max_days), call. = FALSE)
          }
        } else {
          period_days <- switch(period,
            "1d" = 1,
            "5d" = 5,
            "1mo" = 31,
            "3mo" = 92,
            "6mo" = 183,
            "1y" = 365,
            "2y" = 730,
            "5y" = 1825,
            "10y" = 3650,
            "ytd" = as.numeric(difftime(Sys.Date(), lubridate::as_date(paste0(lubridate::year(Sys.Date()), "-01-01")), units = "days")),
            "max" = Inf,
            Inf
          )
          if (period_days > max_days) {
            stop(sprintf("Interval '%s' is limited to a maximum lookback of %d days.", interval, max_days), call. = FALSE)
          }
        }
      }

      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$symbol)

      if (!is.null(start) && !is.null(end)) {
        qlist <- list(period1 = start_date, period2 = end_date, interval = interval)
      } else if (!is.null(start) && is.null(end)) {
        qlist <- list(period1 = start_date, period2 = floor(as.numeric(Sys.time())), interval = interval)
      } else {
        qlist <- list(range = period, interval = interval)
      }

      parsed <- private$api_request(end_point, qlist)

      if (is.null(parsed)) return(invisible(NULL))

      data <- parsed$chart$result[[1]]
      return(parse_chart_data(data, self$symbol))
    }
  ),

  private = list(
    base_url = 'https://query2.finance.yahoo.com',
    cors_domain = 'finance.yahoo.com',

    api_request = function(path, query = list(), headers = list()) {
      url <- paste0(private$base_url, "/", sub("^/", "", path))
      api_request(url, query = query, headers = headers)
    }
  )
)
