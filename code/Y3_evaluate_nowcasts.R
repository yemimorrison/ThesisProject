#### Evaluation of the nowcasting models ####

library(rstan)
library(rstantools)
library(EpiNow2)
library(DBI)
library(RSQLite)

# Import functions
source("./code/Y2_functions.r")

# Import data
dat <- read_csv("./data/covid_cases.csv")

# Restrict dataset to a specific nowcast dates
rep_dates <- list.files(path = paste0("./data/mytests/")) %>% 
  str_extract("[A-Za-z]+ \\d{1,2} \\d{4}") %>%  # Extract "Apr 24 2022"
  parse_date_time("b d Y") %>%  # Convert to Date-Time format
  as.Date() %>%  # Convert to Date format (removes UTC)  
  as.data.frame %>% 
  distinct() %>% 
  filter(. >= "2022-04-01", . <= "2022-12-31") %>%  
  t() %>%
  as.vector()

# Choose one of following models
models <- c("mod_r", "mod_r_cases", "mod_l", "mod_l_cases", 
            "mod_l_2", "mod_rl", "mod_rl_cases", "mod_rl_2")

now <-"2022-07-24"
now <- as.Date(now)

for(i in length(rep_dates)){
  now <- rep_dates[i]
  model_spec <- "mod_r"
  lapply(model_spec , evaluate_nowcast, dat = dat, now = "2022-07-24")
}


