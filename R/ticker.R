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
    #' Retrieves aggregated maturity and duration information for a given symbol
    #' @examples
    #' fund <- Ticker$new('vbmfx')
    #' fund$get_fund_bond_holdings()
    get_fund_bond_holdings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(bondHoldings) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')

    },

    #' @description
    #' Retrieves aggregated maturity and duration information
    #' @examples
    #' fund <- Ticker$new('vbmfx')
    #' fund$get_fund_bond_ratings()
    get_fund_bond_ratings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(bondRatings) %>%
        map_depth(2, 'raw') %>%
        unlist() %>%
        as.list()

    },

    #' @description
    #' Fund equity holdings
    #' @examples
    #' fund <- Ticker$new('vbmfx')
    #' fund$get_fund_equity_holdings()
    get_fund_equity_holdings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(equityHoldings) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')

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
    #' Trend data related to given symbol's index, specificially PE and PEG ratios
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_index_trend()
    get_index_trend = function() {

      module <- 'indexTrend'
      req    <- private$resp_data(self$symbol, module)
      
      resp <- 
        req %>%
        private$display_data() %>%
        use_series(indexTrend)

      symbol <- resp$symbol
      pe_ratio <- resp$peRatio$raw
      peg_ratio <- resp$pegRatio$raw

      estimates <-
        resp %>%
        use_series(estimates) 

      estimates_data <- 
        data.frame(
          period = map_chr(estimates, 'period', .default = NA),
          growth = map_dbl(map(estimates, 'growth'), 'raw', .default = NA)
        )

      list(
        symbol = symbol,
        pe_ratio = pe_ratio,
        peg_ratio = peg_ratio,
        estimates = estimates_data
      )
      
    },

    #' @description
    #' Data related to stock holdings of a given symbol(s) insiders
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_inside_holders()
    get_inside_holders = function() {

      module <- 'insiderHolders'
      req    <- private$resp_data(self$symbol, module)

      resp <- 
        req %>%
        private$display_data() %>%
        use_series(insiderHolders) %>%
        use_series(holders)

      data.frame(
        name = map_chr(resp, 'name', .default = NA),
        relation = map_chr(resp, 'relation', .default = NA),
        url = map_chr(resp, 'url', .default = NA),
        description = map_chr(resp, 'transactionDescription', .default = NA),
        latest_transaction_date = map_chr(map(resp, 'latestTransDate'), 'fmt', .default = NA),
        position_direct = map_dbl(map(resp, 'positionDirect'), 'raw', .default = NA),
        position_direct_date = map_chr(map(resp, 'positionDirectDate'), 'fmt', .default = NA)                        
      )
      
    },

    #' @description
    #' Transactions by insiders for a given symbol(s)
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_insider_transactions()
    get_insider_transactions = function() {

      module <- 'insiderTransactions'
      req    <- private$resp_data(self$symbol, module)

      resp <- 
        req %>%
        private$display_data() %>%
        use_series(insiderTransactions) %>%
        use_series(transactions)

      data.frame(
        start_date = map_chr(map(resp, 'startDate'), 'fmt', .default = NA),                        
        filer_name = map_chr(resp, 'filerName', .default = NA),
        filer_relation = map_chr(resp, 'filerRelation', .default = NA),
        transaction_text = map_chr(resp, 'transactionText', .default = NA),
        ownership = map_chr(resp, 'ownership', .default = NA),
        shares = map_chr(map(resp, 'shares'), 'raw', .default = NA),
        value = map_chr(map(resp, 'value'), 'raw', .default = NA),
        filer_url = map_chr(resp, 'filerUrl', .default = NA),
        money_text = map_chr(resp, 'moneyText', .default = NA)
        
      )
      
    },

    #' @description
    #' Top 10 owners of a given symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_institution_ownership()
    get_institution_ownership = function() {

      module <- 'institutionOwnership'
      req    <- private$resp_data(self$symbol, module)

      resp <- 
        req %>%
        private$display_data() %>%
        use_series(institutionOwnership) %>%
        use_series(ownershipList)

      data.frame(
        date = map_chr(map(resp, 'reportDate'), 'fmt', .default = NA),     
        organization = map_chr(resp, 'organization', .default = NA),                   
        percent_held = map_dbl(map(resp, 'percentHeld'), 'raw', .default = NA),
        position = map_dbl(map(resp, 'position'), 'raw', .default = NA),
        value = map_dbl(map(resp, 'value'), 'raw', .default = NA),
        percent_change = map_dbl(map(resp, 'pctChange'), 'raw', .default = NA)
      )
      
    },

    #' @description
    #' Data showing breakdown of owners of given symbol(s), insiders, institutions, etc.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_major_holders()
    get_major_holders = function() {

      module <- 'majorHoldersBreakdown'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%   
        private$display_data() %>%
        use_series(majorHoldersBreakdown) %>%
        map_at(-1, 'raw')
    },

    #' @description
    #' Short, Mid, and Long-term trend data regarding a symbol's page views
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_page_views()
    get_page_views = function() {

      module <- 'pageViews'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%   
        private$display_data() %>%
        use_series(pageViews) 
    },

    #' @description
    #' Detailed pricing data for given symbol, exchange, quote type, currency, market cap, pre / post market data, etc.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_price()
    get_price = function() {

      module <- 'price'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(price) %>%
        map_at(c(2, 3, 5, 9, 10, 12:16, 19, 21, 42), 'raw')
    },

    #' @description
    #' Stock exchange specific data for given symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_quote_type()
    get_quote_type = function() {

      module <- 'quoteType'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(quoteType)
    },

    #' @description
    #' Data related to historical recommendations (buy, hold, sell) for a given symbol
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_recommendation_trend()
    get_recommendation_trend = function() {

      module <- 'recommendationTrend'
      req    <- private$resp_data(self$symbol, module)

      resp <- 
        req %>%
        private$display_data() %>%
        use_series(recommendationTrend) %>%
        use_series(trend)

      data.frame(
        period = map_chr(resp, 'period', .default = NA),
        strong_buy = map_int(resp, 'strongBuy', .default = NA),                   
        buy = map_int(resp, 'buy', .default = NA),                   
        hold = map_int(resp, 'hold', .default = NA),                   
        sell = map_int(resp, 'sell', .default = NA),                   
        strong_sell = map_int(resp, 'strongSell', .default = NA)                 
      )
      
    },

    #' @description
    #' Historical SEC filings 
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_security_filings()
    get_security_filings = function() {

      module <- 'secFilings'
      req    <- private$resp_data(self$symbol, module)

      resp <- 
        req %>%
        private$display_data() %>%
        use_series(secFilings) %>%
        use_series(filings)

      data.frame(
        date = map_chr(resp, 'date', .default = NA),
        type = map_chr(resp, 'type', .default = NA),
        title = map_chr(resp, 'title', .default = NA),
        edgar_url = map_chr(resp, 'edgarUrl', .default = NA)               
      )
      
    },

    #' @description
    #' High-level buy / sell data
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_share_purchase_activity()
    get_share_purchase_activity = function() {

      module <- 'netSharePurchaseActivity'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(netSharePurchaseActivity) %>%
        map_at(c(-1, -2), 'raw')
    },

    #' @description
    #' Contains information available via the Summary tab in Yahoo Finance
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_summary_detail()
    get_summary_detail = function() {

      module <- 'summaryDetail'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(summaryDetail) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')
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
