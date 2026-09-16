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
#' @aliases Index Index-class
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
    #' @param validate Logical; if TRUE, validate symbol against Yahoo Finance. Defaults to TRUE.
    #' @return A new \code{Index} object.
    #' @examples
    #' \dontrun{
    #' nifty_50 <- Index$new('^NSEI')
    #' }
    initialize = function(symbol = NA, index = NA, validate = TRUE) {
      if (!is.na(index)) {
        warning("The 'index' parameter is deprecated. Please use 'symbol' instead.", call. = FALSE)
        if (is.na(symbol)) symbol <- index
      }
      super$initialize(symbol, validate = validate)
    },

    #' @description
    #' Set a new index symbol.
    #' @param symbol New symbol.
    #' @param index Deprecated. Use \code{symbol} instead.
    #' @param validate Logical; if TRUE, validate symbol against Yahoo Finance. Defaults to TRUE.
    #' @examples
    #' \dontrun{
    #' indice <- Index$new('^NSEI')
    #' indice$set_index('^NDX')
    #' }
    set_index = function(symbol = NA, index = NA, validate = TRUE) {
      if (!is.na(index)) {
        warning("The 'index' parameter is deprecated. Please use 'symbol' instead.", call. = FALSE)
        if (is.na(symbol)) symbol <- index
      }
      self$set_symbol(symbol, validate = validate)
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
