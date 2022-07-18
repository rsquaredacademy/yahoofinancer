#' R6 Class Representing a Ticker
#'
#' @description
#' Base class for getting all data related to ticker from Yahoo Finance API
#'
#' @param symbol Symbol for which data has to be retrieved
#'
#' @import R6 httr jsonlite magrittr purrr lubridate stringr
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
    #' Retrieves balance sheet data for most recent four quarters or most recent four years
    #' @param frequency Annual or quarter.
    #' @param clean_names Logical; if \code{TRUE}, converts column names to snake case.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_balance_sheet('annual')
    #' aapl$get_balance_sheet('quarter')
    get_balance_sheet = function(frequency = c('annual', 'quarter'), clean_names = TRUE) {

      freq <- match.arg(frequency)

      if (freq == 'annual') {
        module <- 'balanceSheetHistory'
      } else {
        module <- 'balanceSheetHistoryQuarterly'
      }

      req  <- private$resp_data(self$symbol, module)

      if (freq == 'annual') {
        data <- 
          req %>% 
          private$display_data() %>%
          use_series(balanceSheetHistory)
      } else {
        data <- 
          req %>% 
          private$display_data() %>%
          use_series(balanceSheetHistoryQuarterly)
      }

      balance_sheet <- 
        data %>% 
        use_series(balanceSheetStatements) %>%
        map_depth(2, 'raw') %>% 
        map_dfr(extract) 

      balance_sheet$endDate <- date(as_datetime(balance_sheet$endDate))

      if (clean_names) {
        names(balance_sheet) <- str_replace_all(names(balance_sheet), '[A-Z]', private$snake_case)
      }
      
      balance_sheet
    },

    #' @description
    #' Retrieves cash flow data for most recent four quarters or most recent four years
    #' @param frequency Annual or quarter.
    #' @param clean_names Logical; if \code{TRUE}, converts column names to snake case.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_cash_flow('annual')
    #' aapl$get_cash_flow('quarter')
    get_cash_flow = function(frequency = c('annual', 'quarter'), clean_names = TRUE) {

      freq <- match.arg(frequency)

      if (freq == 'annual') {
        module <- 'cashflowStatementHistory'
      } else {
        module <- 'cashflowStatementHistoryQuarterly'
      }

      req  <- private$resp_data(self$symbol, module)

      if (freq == 'annual') {
        data <- 
          req %>% 
          private$display_data() %>%
          use_series(cashflowStatementHistory)
      } else {
        data <- 
          req %>% 
          private$display_data() %>%
          use_series(cashflowStatementHistoryQuarterly)
      }

      cash_flow <- 
        data %>% 
        use_series(cashflowStatements) %>%
        map_depth(2, 'raw') %>% 
        map_dfr(extract) 

      cash_flow$endDate <- date(as_datetime(cash_flow$endDate))

      if (clean_names) {
        names(cash_flow) <- str_replace_all(names(cash_flow), '[A-Z]', private$snake_case)
      }
      
      cash_flow
    },

    #' @description
    #' Retrieves income statement data for most recent four quarters or most recent four years
    #' @param frequency Annual or quarter.
    #' @param clean_names Logical; if \code{TRUE}, converts column names to snake case.
    #' @examples
    #' aapl <- Ticker$new('aapl')
    #' aapl$get_income_statement('annual')
    #' aapl$get_income_statement('quarter')
    get_income_statement = function(frequency = c('annual', 'quarter'), clean_names = TRUE) {

      freq <- match.arg(frequency)

      if (freq == 'annual') {
        module <- 'incomeStatementHistory'
      } else {
        module <- 'incomeStatementHistoryQuarterly'
      }

      req  <- private$resp_data(self$symbol, module)

      if (freq == 'annual') {
        data <- 
          req %>% 
          private$display_data() %>%
          use_series(incomeStatementHistory)
      } else {
        data <- 
          req %>% 
          private$display_data() %>%
          use_series(incomeStatementHistoryQuarterly)
      }

      income_statement <- 
        data %>% 
        use_series(incomeStatementHistory) %>%
        map_depth(2, 'raw') %>% 
        map_dfr(extract) 

      income_statement$endDate <- date(as_datetime(income_statement$endDate))

      if (clean_names) {
        names(income_statement) <- str_replace_all(names(income_statement), '[A-Z]', private$snake_case)
      }
      
      income_statement
    }
  ),

  active = list(

    #' @field asset_profile Information related to the company's location, operations, and officers.
    asset_profile = function() {
      module <- 'assetProfile'
      req    <- private$resp_data(self$symbol, module)

      req %>% 
      private$display_data() %>%
        use_series(assetProfile)
    },

    #' @field calendar_events Earnings and Revenue expectations for upcoming earnings date.
    calendar_events = function() {
      module <- 'calendarEvents'
      req    <- private$resp_data(self$symbol, module)
      
      data <-
        req %>%
        private$display_data() %>%
          use_series(calendarEvents) 

      earnings <-
        data %>%
        use_series(earnings) %>%
        map('raw')

      earnings_date <- 
        data %>%
        use_series(earnings) %>%
        use_series(earningsDate) %>%
        map_chr('fmt')

      ex_dividend_date <- 
        data %>%
        use_series(exDividendDate) %>%
        use_series('fmt')

      dividend_date <- 
        data %>%
        use_series(dividendDate) %>%
        use_series('fmt')
        
      earnings$earningsDate <- earnings_date
      earnings$exDividendDate <- ex_dividend_date
      earnings$dividendDate <- dividend_date

      earnings

    },

    #' @field company_officers Retrieves top executives for given symbol and their total pay package.
    company_officers = function() {
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

    #' @field earnings_history Data related to historical earnings (actual vs. estimate)
    earnings_history = function() {

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

    #' @field earnings Historical earnings data.
    earnings = function() {

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

    #' @field earnings_trend Historical trend data for earnings and revenue estimations
    earnings_trend = function() {

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

    #' @field esg_scores Data related to environmental, social, and governance metrics
    esg_scores = function() {

      module <- 'esgScores'
      req    <- private$resp_data(self$symbol, module)
      req %>%  
        private$display_data() %>%
        use_series(esgScores)
    },

    #' @field financial_data  Financial key performance indicators
    financial_data = function() {

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

    #' @field fund_bond_holdings Retrieves aggregated maturity and duration information for a given symbol
    fund_bond_holdings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(bondHoldings) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')

    },

    #' @field fund_bond_ratings Retrieves aggregated maturity and duration information
    fund_bond_ratings = function() {

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

    #' @field fund_equity_holdings Fund equity holdings
    fund_equity_holdings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(equityHoldings) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')

    },

    #' @field fund_holding_info Contains information for a funds top holdings, bond ratings, bond holdings, equity holdings, sector weightings, and category breakdown
    fund_holding_info = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) 

    },

    #' @field fund_ownership Top 10 owners of a given symbol
    fund_ownership = function() {

      module <- 'fundOwnership'
      req    <- private$resp_data(self$symbol, module)

      data <-
        private$display_data(req) %>%
        use_series(fundOwnership) %>%
        use_series(ownershipList)

      data.frame(
        report_date = map_chr(map(data, 'reportDate'), 'fmt', .default = NA),
        organization = map_chr(data, 'organization', .default = NA),
        percent_held = map_dbl(map(data, 'pctHeld'), 'raw', .default = NA),
        position = map_dbl(map(data, 'position'), 'raw', .default = NA),
        value = map_dbl(map(data, 'value'), 'raw', .default = NA),
        percent_change = map_dbl(map(data, 'pctChange'), 'raw', .default = NA)
      )
    },

    #' @field fund_performance Historical return data for a given symbol and its specific category
    fund_performance = function() {

      module <- 'fundPerformance'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(fundPerformance) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')

    },

    #' @field fund_profile Summary level information for a given symbol
    fund_profile = function() {

      module <- 'fundProfile'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(fundProfile) 

    },

    #' @field fund_section_weightings Retrieves aggregated sector weightings for a given symbol
    fund_section_weightings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(sectorWeightings) %>%
        map_depth(2, 'raw') %>%
        unlist() %>%
        as.list()
    },

    #' @field fund_top_holdings Retrieves Top 10 holdings for a given symbol
    fund_top_holdings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      data <- 
        req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        use_series(holdings) 

      data.frame(
        symbol = map_chr(data, 'symbol', .default = NA),
        holding_name = map_chr(data, 'holdingName', .default = NA),
        holding_percent = map_dbl(map(data, 'holdingPercent'), 'raw', .default = NA)
      )
    },

    #' @field fund_holdings Holding info for the given fund
    fund_holdings = function() {

      module <- 'topHoldings'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(topHoldings) %>%
        map_depth(1, 'raw') %>% 
        compact()

    },

    #' @field grading_history Data related to upgrades / downgrades by companies
    grading_history = function() {

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

    #' @field index_trend Trend data related to given symbol's index, specificially PE and PEG ratios
    index_trend = function() {

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

    #' @field inside_holders Data related to stock holdings of a given symbol(s) insiders
    inside_holders = function() {

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

    #' @field insider_transactions Transactions by insiders for a given symbol(s)
    insider_transactions = function() {

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

    #' @field institution_ownership Top 10 owners of a given symbol
    institution_ownership = function() {

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

    #' @field key_stats KPIs for given symbol
    key_stats = function() {

      module <- 'defaultKeyStatistics'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%   
        private$display_data() %>%
        use_series(defaultKeyStatistics) %>%
        compact()
    },

    #' @field major_holders Data showing breakdown of owners of given symbol(s), insiders, institutions, etc.
    major_holders = function() {

      module <- 'majorHoldersBreakdown'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%   
        private$display_data() %>%
        use_series(majorHoldersBreakdown) %>%
        map_at(-1, 'raw')
    },

    #' @field page_views Short, Mid, and Long-term trend data regarding a symbol's page views
    page_views = function() {

      module <- 'pageViews'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%   
        private$display_data() %>%
        use_series(pageViews) 
    },

    #' @field price Detailed pricing data for given symbol, exchange, quote type, currency, market cap, pre / post market data, etc.
    price = function() {

      module <- 'price'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(price) %>%
        map_at(c(2, 3, 5, 9, 10, 12:16, 19, 21, 42), 'raw')
    },

    #' @field quote_type Stock exchange specific data for given symbol
    quote_type = function() {

      module <- 'quoteType'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(quoteType)
    },

    #' @field recommendation_trend Data related to historical recommendations (buy, hold, sell) for a given symbol
    recommendation_trend = function() {

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

    #' @field security_filings Historical SEC filings 
    security_filings = function() {

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

    #' @field share_purchase_activity High-level buy / sell data
    share_purchase_activity = function() {

      module <- 'netSharePurchaseActivity'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(netSharePurchaseActivity) %>%
        map_at(c(-1, -2), 'raw')
    },

    #' @field summary_detail Contains information available via the Summary tab in Yahoo Finance
    summary_detail = function() {

      module <- 'summaryDetail'
      req    <- private$resp_data(self$symbol, module)
      
      req %>%
        private$display_data() %>%
        use_series(summaryDetail) %>%
        compact() %>%
        map_if(function(x) 'raw' %in% names(x), 'raw')
    },

    #' @field summary_profile Return business summary of given symbol
    summary_profile = function() {

      module <- 'summaryProfile'
      req    <- private$resp_data(self$symbol, module)

      req %>%
        private$display_data() %>%
        use_series(summaryProfile)
    },

    #' @field valuation_measures Retrieves valuation measures for most recent four quarters
    valuation_measures = function() {

      url <- 'https://query2.finance.yahoo.com/ws/fundamentals-timeseries/v1/finance/timeseries/aapl?symbol=aapl&padTimeSeries=true&type=quarterlyMarketCap,trailingMarketCap,quarterlyEnterpriseValue,trailingEnterpriseValue,quarterlyPeRatio,trailingPeRatio,quarterlyForwardPeRatio,trailingForwardPeRatio,quarterlyPegRatio,trailingPegRatio,quarterlyPsRatio,trailingPsRatio,quarterlyPbRatio,trailingPbRatio,quarterlyEnterprisesValueRevenueRatio,trailingEnterprisesValueRevenueRatio,quarterlyEnterprisesValueEBITDARatio,trailingEnterprisesValueEBITDARatio&period1=493590046&period2=1658016000&corsDomain=finance.yahoo.com'

      resp   <- GET(url)
      parsed <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)

      data <- 
        parsed %>% 
        use_series(timeseries) %>% 
        use_series(result)

      data.frame(
        date = date(as_datetime(unlist(data[[1]]$timestamp))),
        enterprise_value = private$extract_valuation(data, 'quarterlyEnterpriseValue'),
        enterprise_value_ebitda_ratio = private$extract_valuation(data, 'quarterlyEnterprisesValueEBITDARatio'),
        enterprise_value_revenue_ratio = private$extract_valuation(data, 'quarterlyEnterprisesValueRevenueRatio'),
        forward_pe_ratio = private$extract_valuation(data, 'quarterlyForwardPeRatio'),
        market_cap = private$extract_valuation(data, 'quarterlyMarketCap'),
        pb_ratio = private$extract_valuation(data, 'quarterlyPbRatio'),
        pe_ratio = private$extract_valuation(data, 'quarterlyPeRatio'),
        peg_ratio = private$extract_valuation(data, 'quarterlyPegRatio'),
        ps_ratio = private$extract_valuation(data, 'quarterlyPsRatio')
      )

    },

    #' @field option_chain Option chain data for all expiration dates for a given symbol
    option_chain = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)
      resp      <- GET(url, query = qlist)
      parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
      
      data <- 
        parsed %>%
        use_series(optionChain) %>%
        use_series(result) %>%
        extract2(1) %>% 
        use_series(options) 

      calls <-
        data %>%  
        map_dfr('calls')

      calls$option_type <- 'call'

      puts <- 
        data %>% 
        map_dfr('puts')

      puts$option_type <- 'put'

      result <- rbind(calls, puts)
      names(result) <- str_replace_all(names(result), '[A-Z]', private$snake_case)

      result$expiration <- as_datetime(result$expiration)
      result$last_trade_date <- as_datetime(result$last_trade_date)

      col_order <- c('expiration', 'option_type', 'contract_symbol', 'strike', 'currency', 'last_price', 'change', 'percent_change', 'open_interest', 'bid', 'ask', 'contract_size', 'last_trade_date', 'implied_volatility', 'in_the_money', 'volume')
      
      option_chain <- result[, col_order]
      option_chain

    },

    #' @field option_expiration_dates Option expiration dates
    option_expiration_dates = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)
      resp      <- GET(url, query = qlist)
      parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
      
      parsed %>%
        use_series(optionChain) %>%
        use_series(result) %>%
        extract2(1) %>% 
        use_series(expirationDates) %>% 
        map_dbl(extract) %>% 
        as_datetime() %>% 
        date()

    },

    #' @field option_strikes Option strikes
    option_strikes = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)
      resp      <- GET(url, query = qlist)
      parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
      
      parsed %>%
        use_series(optionChain) %>%
        use_series(result) %>%
        extract2(1) %>% 
        use_series(strikes) %>% 
        map_dbl(extract)

    },

    #' @field option_quote Option quote
    option_quote = function() {

      path      <- 'v7/finance/options/'
      end_point <- paste0(path, self$symbol)
      url       <- modify_url(url = private$base_url, path = end_point)
      qlist     <- list(getAllData = 'True', corsDomain = private$cors_domain)
      resp      <- GET(url, query = qlist)
      parsed    <- jsonlite::fromJSON(content(resp, "text"), simplifyVector = FALSE)
      
      parsed %>%
        use_series(optionChain) %>%
        use_series(result) %>%
        extract2(1) %>% 
        use_series(quote) 

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
    },

    snake_case = function(x) {
      paste0('_', tolower(x))
    },

    extract_valuation = function(data, measure) {
      data %>% 
        map_if(function(x) 'quarterlyEnterpriseValue' %in% names(x), 'quarterlyEnterpriseValue') %>% 
        map_depth(2, 'reportedValue') %>% 
        map_depth(2, 'raw') %>% 
        unlist()
    }
  )
)
