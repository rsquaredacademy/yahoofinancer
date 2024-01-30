#' \code{yahoofinancer} package
#'
#' Fetch Data from Yahoo Finance API
#'
#' See the README on
#' \href{https://github.com/rsquaredacademy/yahoofinancer}{GitHub}
#'
#' @docType package
#' @keywords internal
#' @name yahoofinancer
#' @aliases yahoofinancer-package
"_PACKAGE"

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".", "adjclose", "chart", "currencies", "finance",
   "marketSummaryResponse", "quoteResponse", "result", "volume", "symbolsValidation"))
}
