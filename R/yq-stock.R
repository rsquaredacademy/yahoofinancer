# install and load libraries
# install.packages('httr2')
library(httr2)
library(jsonlite)
library(magrittr)
library(nse2r)

# request
url <- 'https://query1.finance.yahoo.com/v8/finance/chart/INFY.NS?region=US&lang=en-US&includePrePost=false&interval=2m&useYfid=true&range=1d&corsDomain=finance.yahoo.com&.tsrc=finance'
req <- request(url)

# fetch response
resp <- req %>% req_perform()

# extract
data <-
  resp %>%
  resp_body_json() %>%
  use_series(chart) %>%
  use_series(result) %>%
  extract2(1)

meta <- data %>% use_series(meta)
regular_price <- meta %>% use_series(regularMarketPrice)
previous_close <- meta %>% use_series(previousClose)
volume <-
  data %>%
  use_series(indicators) %>%
  use_series(quote) %>%
  extract2(1) %>%
  use_series(volume) %>%
  sapply(., extract, 1) %>%
  sum()

todays_low <-
  data %>%
  use_series(indicators) %>%
  use_series(quote) %>%
  extract2(1) %>%
  use_series(low) %>%
  sapply(sum) %>%
  min()

todays_high <-
  data %>%
  use_series(indicators) %>%
  use_series(quote) %>%
  extract2(1) %>%
  use_series(high) %>%
  sapply(sum) %>%
  max()

change_value <- regular_price - previous_close
change_perc <-
  change_value %>%
  divide_by(previous_close) %>%
  multiply_by(100) %>%
  round(2)


# company name
stock_codes <- nse_stock_code()

stock_codes %>%
  subset(., symbol == symbol) %>%
  use_series(company) %>%
  sub('Limited', '', .) %>%
  trimws()

year_high
