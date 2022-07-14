#' R6 Class Representing a Ticker
#'
#' @description
#' Base class for getting all data related to ticker from Yahoo Finance API
#'
#' @param symbol Symbol for which data has to be retrieved
#'
#' @import R6 httr jsonlite magrittr purrr lubridate
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
        eps_estimate = map_dbl(map(data, 'epsEstimate'), 'raw', .default = NA),
        eps_actual = map_dbl(map(data, 'epsActual'), 'raw', .default = NA),
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

      earnings_data <-
        data.frame(
          date = map_chr(trend, 'endDate', .default = NA),
          period = map_chr(trend, 'period', .default = NA),
          analyst = map_int(map(map(trend, 'earningsEstimate'), 'numberOfAnalysts'), 'raw', .default = NA),
          avg_estimate = map_dbl(map(map(trend, 'earningsEstimate'), 'avg'), 'raw', .default = NA),
          low_estimate = map_dbl(map(map(trend, 'earningsEstimate'), 'low'), 'raw', .default = NA),
          hig_estimate = map_dbl(map(map(trend, 'earningsEstimate'), 'high'), 'raw', .default = NA),
          year_ago_eps = map_dbl(map(map(trend, 'earningsEstimate'), 'yearAgoEps'), 'raw', .default = NA)
        )

        revenue_data <-
        data.frame(
          date = map_chr(trend, 'endDate', .default = NA),
          period = map_chr(trend, 'period', .default = NA),
          analyst = map_int(map(map(trend, 'revenueEstimate'), 'numberOfAnalysts'), 'raw', .default = NA),
          avg_estimate = map_dbl(map(map(trend, 'revenueEstimate'), 'avg'), 'raw', .default = NA),
          low_estimate = map_dbl(map(map(trend, 'revenueEstimate'), 'low'), 'raw', .default = NA),
          hig_estimate = map_dbl(map(map(trend, 'revenueEstimate'), 'high'), 'raw', .default = NA),
          year_ago_revenue = map_dbl(map(map(trend, 'revenueEstimate'), 'yearAgoRevenue'), 'raw', .default = NA)
        )

        eps_trend <-
        data.frame(
          date = map_chr(trend, 'endDate', .default = NA),
          period = map_chr(trend, 'period', .default = NA),
          current = map_dbl(map(map(trend, 'epsTrend'), 'current'), 'raw', .default = NA),
          seven_days_ago = map_dbl(map(map(trend, 'epsTrend'), '7daysAgo'), 'raw', .default = NA),
          thirty_days_ago = map_dbl(map(map(trend, 'epsTrend'), '30daysAgo'), 'raw', .default = NA),
          sixty_days_ago = map_dbl(map(map(trend, 'epsTrend'), '60daysAgo'), 'raw', .default = NA),
          ninety_days_ago = map_dbl(map(map(trend, 'epsTrend'), '90daysAgo'), 'raw', .default = NA)
        )

        eps_revision <-
        data.frame(
          date = map_chr(trend, 'endDate', .default = NA),
          period = map_chr(trend, 'period', .default = NA),
          up_last_7_days = map_dbl(map(map(trend, 'epsRevisions'), 'upLast7days'), 'raw', .default = NA),
          up_last_30_days = map_dbl(map(map(trend, 'epsRevisions'), 'upLast30days'), 'raw', .default = NA),
          down_last_30_days = map_dbl(map(map(trend, 'epsRevisions'), 'downLast30days'), 'raw', .default = NA),
          down_last_90_days = map_dbl(map(map(trend, 'epsRevisions'), 'downLast90days'), 'raw', .default = NA)
        )        

      list(
        growth = growth_data,
        earnings_estimate = earnings_data,
        revenue_estimate = revenue_data,
        eps_trend = eps_trend,
        eps_revision = eps_revision
      )
    },

    #' @description
    #' Data related to environmental, social, and governance metrics
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_esg_scores()
    get_esg_scores = function() {

      module <- 'esgScores'
      req    <- private$resp_data(self$symbol, module)
      req %>%  
        private$display_data() %>%
        use_series(esgScores)
    },

    #' @description
    #' Financial key performance indicators
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_financial_data()
    get_financial_data = function() {

      module <- 'financialData'
      req    <- private$resp_data(self$symbol, module)
      
      data <- 
        req %>%
        private$display_data() %>%
        use_series(financialData) 

      fd <- map(data, 'raw')      
      fd$recommendationKey <- data$recommendationKey
      fd$financialCurrency <- data$financialCurrency
      fd
    },

    #' @description
    #' Data related to upgrades / downgrades by companies
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_grading_history()
    get_grading_history = function() {

      module <- 'upgradeDowngradeHistory'
      req    <- private$resp_data(self$symbol, module)
      
      data <- 
        req %>%
        private$display_data() %>%
        use_series(upgradeDowngradeHistory) %>%
        use_series(history)

      data.frame(
        date = date(as_datetime(map_int(data, 'epochGradeDate', .default = NA))),
        firm = map_chr(data, 'firm', .default = NA),
        to_grade = map_chr(data, 'toGrade', .default = NA),
        from_grade = map_chr(data, 'fromGrade', .default = NA),
        action = map_chr(data, 'action', .default = NA)
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
