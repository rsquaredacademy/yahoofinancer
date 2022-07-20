#' R6 Class Representing a Ticker
#' 
#' @description 
#' Base class for getting all data related to indices from Yahoo Finance API
#' 
#' @param index Index for which data has to be retrieved
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
      self$index <- index
    },

    #' @description
    #' Set a new index.
    #' @param index New index
    #' @examples
    #' indice <- Index$new('^NSEI')
    #' indice$set_index('^NDX')
    set_index = function(index) {
      self$index <- index
    }
  ),
  active = list(

    #' @field summary_detail Contains information available via the Summary tab in Yahoo Finance
    summary_detail = function() {
      
      path   <- 'v7/finance/quote'
      url    <- modify_url(url = private$base_url, path = path)
      qlist  <- list(symbols = self$index)
      resp   <- GET(url, query = qlist)
      parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

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