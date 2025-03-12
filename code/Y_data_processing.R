#### This document is for computing the elements of the reporting triangle of COVID-19 deaths
#### reported by the Swedish Public Health Agency Folkhälsomyndigheten (fohm)

# Libraries
# if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, data.table, lubridate, readxl, readr, zoo, splitstackshape, stringr
)

# File path
path <- "./data/mytests/"

# File path
path <- "./data/mytests/"

# Get file names from fohm
fohm_files <- str_c(path, list.files(path))

# Extract and convert to Date format (removing UTC)
rep_dates <- fohm_files %>%
  str_extract("[A-Za-z]+ \\d{1,2} \\d{4}") %>%  # Extract "Apr 24 2022"
  parse_date_time("b d Y") %>%  # Convert to Date-Time format
  as.Date()  # Convert to Date format (removes UTC)

names(fohm_files) <- rep_dates

# Import covid counts data
covid_cases_df <- lapply(fohm_files, read_excel,
                         sheet = 1, col_types = c("text", "numeric","numeric","numeric","numeric",
                                                  "numeric","numeric","numeric","numeric","numeric",
                                                  "numeric","numeric","numeric","numeric","numeric",
                                                  "numeric","numeric","numeric","numeric","numeric",
                                                  "numeric","numeric","numeric")
) %>%
  bind_rows(.id = "rep_date") %>%
  select(event_date = Statistikdatum, N = Totalt_antal_fall, rep_date) %>%
  filter(event_date != "Uppgift saknas") %>%
  mutate(
    event_date = as.Date(as.numeric(event_date), origin = "1899-12-30"),
    rep_date = as.Date(rep_date)
  )

# Compute cases n_t,d's
covid_cases_df %>%
  group_by(event_date) %>%
  mutate(n = c(first(N), diff(N))) %>%
  filter( # date > as_date("2020-05-01"),
    n > 0
  ) %>%
  select(event_date, n, rep_date) %>%
  write_csv("./data/covid_cases.csv")

#Haven't done ICU yet.