#' R6 Class Representing a Ticker
#' 
#' @description 
#' Base class for getting all data related to indices from Yahoo Finance API.
#' 
#' @param index Index for which data has to be retrieved.
#' 
#' @docType class
#' @format An R6 class object
#' @name Index-class
#' 
#' @export 
Index <- R6::R6Class(

  "Index",

  public = list(

    #' @field index Index for which data is retrieved
    index = NULL,

    #' @description
    #' Create a new Index object
    #' @param index Index
    #' @examples
    #' nifty_50 <- Index$new('^NSEI')
    #' @return A new `Index` object
    initialize = function(index = NA) {
      if (validate(index)) {
        self$index <- index
      } else {
        stop("Not a valid index.", call. = FALSE)
      }
    },

    #' @description
    #' Set a new index.
    #' @param index New index
    #' @examples
    #' indice <- Index$new('^NSEI')
    #' indice$set_index('^NDX')
    set_index = function(index) {
      if (validate(index)) {
        self$index <- index
      } else {
        stop("Not a valid index.", call. = FALSE)
      }
    },

    #' @description 
    #' Retrieves historical data
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
    #' @param start Specific starting date.
    #' @param end Specific ending date.
    #' @return A \code{data.frame}.
    #' @examples
    #' \donttest{
    #' nifty <- Index$new('^NSEI')
    #' nifty$get_history(start = '2022-07-01', interval = '1d')
    #' nifty$get_history(start = '2022-07-01', end = '2022-07-14', interval = '1d')
    #' nifty$get_history(period = '1mo', interval = '1d')
    #' }
    get_history = function(period = 'ytd', interval = '1d', start = NULL, end = NULL) {

      if (!is.null(start)) {
        start_date <- as.numeric(as.POSIXct(ymd(start)))
      }

      if (!is.null(end)) {
        end_date <- as.numeric(as.POSIXct(ymd(end)))
      }

      path      <- 'v8/finance/chart/'
      end_point <- paste0(path, self$index)
      url       <- modify_url(url = private$base_url, path = end_point)

      if (!is.null(start) && !is.null(end)) {
        qlist <- list(period1 = start_date, period2 = end_date, interval = interval)
      } else if (!is.null(start) && is.null(end)) {
        qlist <- list(period1 = start_date, period2 = round(as.numeric(as.POSIXct(now()))), interval = interval)
      } else {
        qlist <- list(range = period, interval = interval)
      }

      resp      <- GET(url, query = qlist)
      parsed    <- fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)
      
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
        volume = flatten_list(indicators$volume),
        high   = flatten_list(indicators$high),
        low    = flatten_list(indicators$low),
        open   = flatten_list(indicators$open),
        close  = flatten_list(indicators$close)
      )

      intervals <- c('1d', '5d', '1wk', '1mo', '3mo')

      if (interval %in% intervals) {
        adj_close <-
          data %>%
          use_series(indicators) %>%
          use_series(adjclose) %>%
          extract2(1) %>%
          use_series(adjclose) %>%
          unlist()

        result$adj_close <- adj_close

      }

      result

    }
  ),

  active = list(

    #' @field summary_detail Contains information available via the Summary tab in Yahoo Finance
    summary_detail = function() {
      
      path   <- 'v7/finance/quote'
      url    <- modify_url(url = private$base_url, path = path)
      qlist  <- list(symbols = self$index)
      resp   <- GET(url, query = qlist)
      parsed <- fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

      parsed %>%
        use_series(quoteResponse) %>%
        use_series(result) %>%
        extract2(1)
        
    }
  ),

  private = list(
    base_url = 'https://query2.finance.yahoo.com'
  )
)