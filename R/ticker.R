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
    #' Retrieves top executives for given symbol and their total pay package.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_company_officers()
    get_company_officers = function() {
      data <-
        self$get_asset_profile() %>%
        use_series(companyOfficers)

      data.frame(
        name = map_chr(data, 'name'),
        age = map_int(data, 'age', .default = NA),
        title = map_chr(data, 'title', .default = NA),
        year_born = map_int(data, 'yearBorn', .default = NA),
        fiscal_year = map_int(data, 'fiscalYear', .default = NA),
        total_pay = map_dbl(map(data, 'totalPay'), 'raw', .default = NA),
        exercised_value = map_dbl(map(data, 'exercisedValue'), 'raw', .default = NA),
        unexercised_value = map_dbl(map(data, 'unexercisedValue'), 'raw', .default = NA)
      )
    },

    #' @description
    #' Data related to historical earnings (actual vs. estimate)
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_earnings_history()
    get_earnings_history = function() {

      module <- 'earningsHistory'
      req    <- private$resp_data(self$symbol, module)

      data <-
        private$display_data(req) %>%
        use_series(earningsHistory) %>%
        use_series(history)

      data.frame(
        quarter = map_chr(map(data, 'quarter'), 'fmt', .default = NA),
        period = map_chr(data, 'period', .default = NA),
        eps_actual = map_dbl(map(data, 'epsActual'), 'raw', .default = NA),
        eps_estimate = map_dbl(map(data, 'epsEstimate'), 'raw', .default = NA),
        eps_difference = map_dbl(map(data, 'epsDifference'), 'raw', .default = NA),
        surprise_percent = map_dbl(map(data, 'surprisePercent'), 'raw', .default = NA)
      )
    },

    #' @description
    #' Historical earnings data.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_earnings()
    get_earnings = function() {

      module <- 'earnings'
      req    <- private$resp_data(self$symbol, module)
      
      earnings <- 
        req %>%
        private$display_data() %>%
        use_series(earnings) 
        
      estimate <- 
        earnings %>%
        use_series(earningsChart) %>%
        use_series(quarterly)

      earnings_estimate <-
        data.frame(
          date = map_chr(estimate, 'date'),
          actual = map_dbl(map(estimate, 'actual'), 'raw', .default = NA),
          estimate = map_dbl(map(estimate, 'estimate'), 'raw', .default = NA)
        )

      current_quarter <- list(
        estimate = earnings$earningsChart$currentQuarterEstimate$raw,
        estimate_date = earnings$earningsChart$currentQuarterEstimateDate,
        estimate_year = earnings$earningsChart$currentQuarterEstimateYear
      )

      yearly <-
        earnings %>%
        use_series(financialsChart) %>%
        use_series(yearly)

      yearly_estimate <-
        data.frame(
          date = map_chr(yearly, 'date'),
          earnings = map_dbl(map(yearly, 'earnings'), 'raw', .default = NA),
          revenue = map_dbl(map(yearly, 'revenue'), 'raw', .default = NA)
        )

      quarterly <-
        earnings %>%
        use_series(financialsChart) %>%
        use_series(quarterly)

      quarterly_estimate <-
        data.frame(
          date = map_chr(quarterly, 'date'),
          earnings = map_dbl(map(quarterly, 'earnings'), 'raw', .default = NA),
          revenue = map_dbl(map(quarterly, 'revenue'), 'raw', .default = NA)
        )

      list(
        earnings_estimate = earnings_estimate,
        current_quarter = current_quarter,
        yearly_earnings_revenue = yearly_estimate,
        quarterly_earnings_revenue = quarterly_estimate
      )
    },

    #' @description
    #' Historical trend data for earnings and revenue estimations
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_earnings_trend()
    get_earnings_trend = function() {

      module <- 'earningsTrend'
      req    <- private$resp_data(self$symbol, module)
      
      trend <- 
        req %>%
        private$display_data() %>%
        use_series(earningsTrend) %>%
        use_series(trend)

      growth_data <-
        data.frame(
          date = map_chr(trend, 'endDate', .default = NA),
          period = map_chr(trend, 'period', .default = NA),
          growth = map_dbl(map(trend, 'growth'), 'raw', .default = NA)
        )

      list(
        growth = growth_data
      )
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
