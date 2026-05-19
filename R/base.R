#' R6 Class Representing a Yahoo Finance Base Object
#'
#' @description
#' Base class for Ticker and Index classes.
#'
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON
#' @import R6 httr purrr lubridate
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
      if (validate(symbol)) {
        self$symbol <- symbol
      } else {
        stop("Not a valid symbol.", call. = FALSE)
      }
    },

    #' @description
    #' Set a new symbol.
    #' @param symbol New symbol
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
      if (is.null(data$timestamp)) return(data.frame())

      indicators <- data$indicators$quote[[1]]

      result <- data.frame(
        date   = lubridate::as_datetime(unlist(data$timestamp)),
        volume = flatten_list(indicators$volume),
        high   = flatten_list(indicators$high),
        low    = flatten_list(indicators$low),
        open   = flatten_list(indicators$open),
        close  = flatten_list(indicators$close),
        stringsAsFactors = FALSE
      )

      if (interval %in% c('1d', '5d', '1wk', '1mo', '3mo')) {
        adj_close <- unlist(data$indicators$adjclose[[1]]$adjclose)
        if (!is.null(adj_close) && length(adj_close) == nrow(result)) {
          result$adj_close <- adj_close
        }
      }

      return(result)
    }
  ),

  private = list(
    base_url = 'https://query2.finance.yahoo.com',
    cors_domain = 'finance.yahoo.com',

    api_request = function(path, query = list()) {
      url <- httr::modify_url(url = private$base_url, path = path)

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(NULL)
      }

      resp   <- httr::GET(url, query = query)
      parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      if (httr::http_error(resp)) {
        # Standardize error reporting
        err_msg <- if (!is.null(parsed$chart$error$description)) {
          parsed$chart$error$description
        } else if (!is.null(parsed$quoteSummary$error$description)) {
          parsed$quoteSummary$error$description
        } else {
          "Unknown Error"
        }
        warning(sprintf("Yahoo Finance API failed [%s]: %s", httr::status_code(resp), err_msg), call. = FALSE)
        return(NULL)
      }

      return(parsed)
    }
  )
)
