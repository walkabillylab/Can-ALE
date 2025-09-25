##PE##

library(httr)

# Set working directory
setwd("V:/CanALE/Data/GTFS/GTFS_2021/PE")

# Base URL for PE Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/t3-transit/591"

# Check for valid GTFS data availability
is_valid_date <- function(date) {
  # Exclude weekends (Saturday and Sunday)
  if (weekdays(date) %in% c("Saturday", "Sunday")) return(FALSE)
  
  # Exclude federal or provincial holidays
  holidays <- as.Date(c(
    "2021-02-15", # Islander Day (statutory)
    "2021-04-02", # Good Friday (statutory)
    "2021-04-05", # Easter Monday (non-statutory, often observed)
    "2021-05-24", # Victoria Day (non-statutory in PEI)
    "2021-07-01", # Canada Day (statutory)
    "2021-08-20", # Gold Cup & Saucer Parade Day (Charlottetown area)
    "2021-09-06", # Labour Day (statutory)
    "2021-10-11", # Thanksgiving (statutory)
    "2021-11-11"  # Remembrance Day (statutory)
  ))
  
  if (date %in% holidays) return(FALSE)
  
  return(TRUE)
}

# Date ranges for 2021
date_ranges <- list(
  seq(as.Date("2021-09-01"), as.Date("2021-09-30"), by = "day"),
  seq(as.Date("2021-10-01"), as.Date("2021-10-31"), by = "day"),
  seq(as.Date("2021-11-01"), as.Date("2021-11-30"), by = "day"),
  seq(as.Date("2021-01-16"), as.Date("2021-01-31"), by = "day"),
  seq(as.Date("2021-02-01"), as.Date("2021-02-28"), by = "day"),
  seq(as.Date("2021-03-01"), as.Date("2021-03-31"), by = "day"),
  seq(as.Date("2021-04-01"), as.Date("2021-04-30"), by = "day"),
  seq(as.Date("2021-12-01"), as.Date("2021-12-15"), by = "day"),
  seq(as.Date("2021-05-01"), as.Date("2021-05-31"), by = "day"),
  seq(as.Date("2021-06-01"), as.Date("2021-06-30"), by = "day"),
  seq(as.Date("2021-07-01"), as.Date("2021-07-31"), by = "day"),
  seq(as.Date("2021-08-01"), as.Date("2021-08-31"), by = "day")
)

# Flag to check if GTFS data is found
gtfs_found <- FALSE

# Iterate through the date ranges
for (date_range in date_ranges) {
  for (date in date_range) {
    # Ensure 'date' is a Date object
    date <- as.Date(date, origin = "1970-01-01") 
    
    if (is_valid_date(date)) {
      # Format the date for TransitFeeds
      date_formatted <- format(date, "%Y%m%d")
      
      # Construct the download URL (adjust if TransitFeeds structure changes)
      gtfs_url <- paste0(base_url, "/", date_formatted, "/download")
      
      # Try downloading GTFS data
      response <- tryCatch({
        HEAD(gtfs_url)
      }, error = function(e) {
        NULL
      })
      
      if (!is.null(response) && response$status_code == 200) {
        # Create a folder named after the date
        date_folder <- format(date, "%Y-%m-%d")
        dir.create(date_folder, showWarnings = FALSE)
        
        # Save the GTFS file in the date-specific folder
        local_file <- file.path(date_folder, "T3 Transit.zip")
        download.file(gtfs_url, local_file, mode = "wb")
        
        message("GTFS data downloaded for date: ", date)
        gtfs_found <- TRUE
        break
      }
    }
  }
  if (gtfs_found) break
}

# If no GTFS file was found
if (!gtfs_found) {
  message("No GTFS data found with the specified criteria.")
}




