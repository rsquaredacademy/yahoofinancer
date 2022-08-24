#' \code{yahoofinancer} package
#' 
#' Fetch Data from Yahoo Finance API
#' 
#' See the README on
#' \href{https://github.com/rsquaredacademy/yahoofinancer}{GitHub}
#' 
#' @docType package
#' @name yahoofinancer
NULL

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".", "adjclose", "chart", "currencies", "finance",
   "marketSummaryResponse", "quoteResponse", "result", "volume"))
}