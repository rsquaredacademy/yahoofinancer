library(httr2)
library(jsonlite)
library(magrittr)

build_url <- function(symbol, module) {
  base_url <- 'https://query1.finance.yahoo.com/v10/finance/quoteSummary/'
  lang_region <- '?lang=en-US&region=US&modules='
  cors_domain <- '&corsDomain=finance.yahoo.com'
  paste0(base_url, symbol, lang_region, module, cors_domain)

}

extract_data <- function(url) {
  req <- request(url)
  resp <- req %>% req_perform()
  resp %>%
    resp_body_json() %>%
    use_series(quoteSummary) %>%
    use_series(result) %>%
    extract2(1)
}

# asset profile
yfr_asset_profile <- function(symbol) {
  module <- 'assetProfile'
  url <- build_url(symbol, module)
  extract_data(url)
}

# company officers
yfr_company_officers <- function(symbol) {
  yfr_asset_profile(symbol) %>%
    use_series(assetProfile) %>%
    use_series(companyOfficers)
}

# calendar events
yfr_calendar_events <- function(symbol) {
  module <- 'calendarEvents'
  url <- build_url(symbol, module)

  url %>%
    extract_data() %>%
    use_series(calendarEvents)
}

# earnings history
yfr_earnings_history <- function(symbol) {
  module <- 'earningsHistory'
  url <- build_url(symbol, module)

  url %>%
    extract_data() %>%
    use_series(earningsHistory)
}

yfr_earnings <- function(symbol) {
  module <- 'earnings'
  url <- build_url(symbol, module)

  url %>%
    extract_data() %>%
    use_series(earnings)
}

yfr_earnings_trend <- function(symbol) {
  module <- 'earningsTrend'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(earningsTrend) %>%
    use_series(trend)
}

yfr_esg_scores <- function(symbol) {
  module <- 'esgScores'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(esgScores)
}

yfr_financial_data <- function(symbol) {
  module <- 'financialData'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(financialData)
}

yfr_fund_top_holdings <- function(symbol) {
  module <- 'topHoldings'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(topHoldings)
}

yfr_fund_bond_holdings <- function(symbol) {
  yfr_fund_top_holdings(symbol) %>%
    use_series(bondHoldings)
}

yfr_fund_bond_ratings <- function(symbol) {
  yfr_fund_top_holdings(symbol) %>%
    use_series(bondRatings)
}

yfr_fund_equity_holdings <- function(symbol) {
  yfr_fund_top_holdings(symbol) %>%
    use_series(equityHoldings)
}

yfr_fund_holding_info <- function(symbol) {
  yfr_fund_top_holdings(symbol) %>%
    use_series(holdings)
}

yfr_fund_sector_weightings <- function(symbol) {
  yfr_fund_top_holdings(symbol) %>%
    use_series(sectorWeightings)
}

yfr_fund_ownership <- function(symbol) {
  module <- 'fundOwnership'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(fundOwnership)
}

yfr_fund_performance <- function(symbol) {
  module <- 'fundPerformance'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(fundPerformance)
}

yfr_fund_profile <- function(symbol) {
  module <- 'fundProfile'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(fundProfile)
}

yfr_grading_history <- function(symbol) {
  module <- 'upgradeDowngradeHistory'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(upgradeDowngradeHistory)
}

yfr_index_trend <- function(symbol) {
  module <- 'indexTrend'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(indexTrend)
}


yfr_insider_holders <- function(symbol) {
  module <- 'insiderHolders'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(insiderHolders)
}

yfr_insider_transactions <- function(symbol) {
  module <- 'insiderTransactions'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(insiderTransactions)
}

yfr_institution_ownership <- function(symbol) {
  module <- 'institutionOwnership'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(institutionOwnership)
}

yfr_key_stats <- function(symbol) {
  module <- 'defaultKeyStatistics'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(defaultKeyStatistics)
}

yfr_major_holders <- function(symbol) {
  module <- 'majorHoldersBreakdown'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(majorHoldersBreakdown)
}

yfr_page_views <- function(symbol) {
  module <- 'pageViews'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(pageViews)
}

yfr_price <- function(symbol) {
  module <- 'price'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(price)
}

yfr_quote_type <- function(symbol) {
  module <- 'quoteType'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(quoteType)
}

yfr_recommendation_trend <- function(symbol) {
  module <- 'recommendationTrend'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(recommendationTrend)
}

yfr_security_filings <- function(symbol) {
  module <- 'secFilings'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(secFilings)
}

yfr_share_purchase_activity <- function(symbol) {
  module <- 'netSharePurchaseActivity'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(netSharePurchaseActivity)
}

yfr_summary_detail <- function(symbol) {
  module <- 'summaryDetail'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(summaryDetail)
}

yfr_summary_profile <- function(symbol) {
  module <- 'summaryProfile'
  url <- build_url(symbol, module)
  url %>%
    extract_data() %>%
    use_series(summaryProfile)
}


