library(httr)

# Set working directory
setwd("V:/CanALE/Data/")

# Install required libraries
install.packages(c("cancensus", "dplyr", "writexl"))

# Load libraries
library(cancensus)
library(dplyr)
library(writexl)

# Set your CensusMapper API key
options(cancensus.api_key = "CensusMapper_723e3f4e60999d1127c93026d17c3b50")

# Download data for all provinces and territories at the DA level
da_data <- get_census(
  dataset = "CA21",             # Census dataset (2021)
  regions = list(C = "01"),     # Region code for Canada (entire country)
  vectors = c("v_CA16_488"),    # Variable for private dwellings
  level = "DA",                 # Dissemination Area level
  geo_format = "sf"             # Get spatial data
)

# Add Province/Territory Code and Name based on the GeoUID structure
final_data <- da_data %>%
  mutate(
    `Province Code` = substr(GeoUID, 1, 2),  # First two digits of GeoUID represent the province/territory
    `Province Name` = case_when(
      `Province Code` == "10" ~ "Newfoundland and Labrador",
      `Province Code` == "11" ~ "Prince Edward Island",
      `Province Code` == "12" ~ "Nova Scotia",
      `Province Code` == "13" ~ "New Brunswick",
      `Province Code` == "24" ~ "Quebec",
      `Province Code` == "35" ~ "Ontario",
      `Province Code` == "46" ~ "Manitoba",
      `Province Code` == "47" ~ "Saskatchewan",
      `Province Code` == "48" ~ "Alberta",
      `Province Code` == "59" ~ "British Columbia",
      `Province Code` == "60" ~ "Yukon Territory",
      `Province Code` == "61" ~ "Northwest Territories",
      `Province Code` == "62" ~ "Nunavut",
      TRUE ~ "Other"
    )
  ) %>%
  select(
    DAUID = GeoUID,                  # DA Unique Identifier
    `Province Code`,                 # Province Code
    `Province Name`,                 # Province Name
    `Dwelling Count` = Dwellings     # Private Dwelling Count
  )

# Write the data to an Excel file
write_xlsx(final_data, "private_dwellings_2021.xlsx")

# Message to indicate completion
cat("Data has been saved to 'private_dwellings_2021.xlsx'\n")
