#' R6 Class Representing an Index
#'
#' @description
#' Class for retrieving data related to market indices from the Yahoo Finance API.
#' Inherits \code{get_history()} from \code{\link{YahooFinanceBase-class}}.
#'
#' @param symbol Symbol for which data has to be retrieved (e.g., \code{"^GSPC"}).
#' @param index Deprecated. Use \code{symbol} instead.
#'
#' @docType class
#' @format An R6 class object
#' @name Indice-class
#' @aliases Index-class
#'
#' @family historical data
#'
#' @export
Index <- R6::R6Class(

  "Index",
  inherit = YahooFinanceBase,

  public = list(

    #' @description
    #' Create a new Index object.
    #' @param symbol Symbol (e.g., \code{"^NSEI"}).
    #' @param index Deprecated. Use \code{symbol} instead.
    #' @return A new \code{Index} object.
    #' @examples
    #' \dontrun{
    #' nifty_50 <- Index$new('^NSEI')
    #' }
    initialize = function(symbol = NA, index = NA) {
      if (!is.na(index)) {
        warning("The 'index' parameter is deprecated. Please use 'symbol' instead.", call. = FALSE)
        if (is.na(symbol)) symbol <- index
      }
      super$initialize(symbol)
    },

    #' @description
    #' Set a new index symbol.
    #' @param symbol New symbol.
    #' @param index Deprecated. Use \code{symbol} instead.
    #' @examples
    #' \dontrun{
    #' indice <- Index$new('^NSEI')
    #' indice$set_index('^NDX')
    #' }
    set_index = function(symbol = NA, index = NA) {
      if (!is.na(index)) {
        warning("The 'index' parameter is deprecated. Please use 'symbol' instead.", call. = FALSE)
        if (is.na(symbol)) symbol <- index
      }
      self$set_symbol(symbol)
    }
  ),

  active = list(
    #' @field index Deprecated. Returns \code{self$symbol}.
    index = function(value) {
      if (missing(value)) {
        warning("The 'index' field is deprecated. Please use 'symbol' instead.", call. = FALSE)
        return(self$symbol)
      } else {
        warning("The 'index' field is deprecated. Please use 'symbol' instead.", call. = FALSE)
        self$set_symbol(value)
      }
    }
  )
)
