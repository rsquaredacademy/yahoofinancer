#' R6 Class Representing a Ticker
#'
#' @description
#' Base class for getting all data related to ticker from Yahoo Finance API
#'
#' @param symbol Symbol for which data has to be retrieved
#'
#' @import R6 httr jsonlite magrittr purrr
#' @docType class
#' @format An R6 class object
#' @name Ticker-class
#'
#' @export
Ticker <- R6::R6Class(

  "Ticker",

  public = list(

    #' @field symbol Symbol for which data is retrieved
    symbol = NULL,

    #' @description
    #' Create a new Ticker object
    #' @param symbol Symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' @return A new `Ticker` object
    initialize = function(symbol = NA) {
      self$symbol <- symbol
    },

    #' @description
    #' Set a new symbol.
    #' @param symbol New symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' appl$set_symbol('msft')
    set_symbol = function(symbol) {
      self$symbol <- symbol
    },

    #' @description
    #' Information related to the company's location, operations, and officers.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_asset_profile()
    get_asset_profile = function() {
      module <- 'assetProfile'
      req    <- private$resp_data(self$symbol, module)
      private$display_data(req) %>%
        use_series(assetProfile)
    },

    #' @description
    #' Earnings and Revenue expectations for upcoming earnings date.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_calendar_events()
    get_calendar_events = function() {
      module <- 'calendarEvents'
      req    <- private$resp_data(self$symbol, module)
      private$display_data(req) %>%
        use_series(calendarEvents) %>%
        use_series(earnings) %>%
        map(., 'raw')
    },

    #' @description
    #' Return business summary of given symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_summary_profile()
    get_summary_profile = function() {

      module <- 'summaryProfile'
      req    <- private$resp_data(self$symbol, module)
      private$display_data(req) %>%
        use_series(summaryProfile)
    }
  ),

  private = list(
    base_url = 'https://query1.finance.yahoo.com',
    path = 'v10/finance/quoteSummary/',
    cors_domain = 'finance.yahoo.com',

    resp_data = function(symbol, module) {
      end_point <- paste0(private$path, symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(modules = module, corsDomain = private$cors_domain)
      resp      <- GET(url, query = qlist)
      parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
      list(resp = resp, parsed = parsed)
    },

    parse_data = function(parsed) {
      parsed %>%
          use_series(quoteSummary) %>%
          use_series(result) %>%
          extract2(1)
    },

    display_error = function(resp, parsed) {
      cat(
        "Yahoo Finance API request failed", '\n',
        paste('Status:', status_code(resp)), '\n',
        paste('Type:', http_status(resp)$category), '\n',
        paste('Mesage:', parsed$quoteSummary$error$code), '\n',
        paste('Description:', parsed$quoteSummary$error$description, '\n'),
        sep = ''
      )
    },

    display_data = function(req) {
      if (http_error(req$resp)) {
        stop(private$display_error(req$resp, req$parsed), call. = FALSE)
      } else {
        private$parse_data(req$parsed) 
      }
    }
  )
)
