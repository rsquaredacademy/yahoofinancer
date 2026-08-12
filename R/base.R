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

    api_request = function(path, query = list(), headers = list()) {
      url <- paste0(private$base_url, "/", sub("^/", "", path))

      if (!curl::has_internet()) {
        message("No internet connection.")
        return(NULL)
      }

      req <- httr2::request(url)
      req <- httr2::req_user_agent(req, "yahoofinancer")

      if (length(headers) > 0) {
        req <- do.call(httr2::req_headers, c(list(req), headers))
      }

      if (length(query) > 0) {
        req <- do.call(httr2::req_url_query, c(list(req), query))
      }

      req <- httr2::req_retry(req, max_tries = 4, backoff = function(re_try) 2^re_try)
      req <- httr2::req_timeout(req, 15)
      req <- httr2::req_error(req, is_error = function(resp) FALSE)

      resp <- tryCatch(
        httr2::req_perform(req),
        error = function(e) NULL
      )

      if (is.null(resp)) return(NULL)

      parsed <- tryCatch(
        httr2::resp_body_json(resp, simplifyVector = FALSE),
        error = function(e) list()
      )

      if (httr2::resp_is_error(resp)) {
        # Standardize error reporting
        err_msg <- if (!is.null(parsed$chart$error$description)) {
          parsed$chart$error$description
        } else if (!is.null(parsed$quoteSummary$error$description)) {
          parsed$quoteSummary$error$description
        } else {
          "Unknown Error"
        }
        warning(sprintf("Yahoo Finance API failed [%s]: %s", httr2::resp_status(resp), err_msg), call. = FALSE)
        return(NULL)
      }

      return(parsed)
    }
  )
)
