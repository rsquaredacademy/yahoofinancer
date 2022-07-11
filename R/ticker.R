library(httr2)
library(jsonlite)
library(magrittr)

build_url <- function(symbol, module) {
  base_url <- 'https://query1.finance.yahoo.com/v10/finance/quoteSummary/'
  lang_region <- '.NS?lang=en-US&region=US&modules='
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
