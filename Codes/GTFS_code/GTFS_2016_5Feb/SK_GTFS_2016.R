##SK##

library(httr)

# Set working directory

setwd("V:/CanALE/Data/GTFS/GTFS_2016/SK")


# Base URL for AB Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/city-of-saskatoon/264"

# Check for valid GTFS data availability
is_valid_date <- function(date) {
  # Exclude weekends (Saturday and Sunday)
  if (weekdays(date) %in% c("Saturday", "Sunday")) return(FALSE)
  
  # Exclude federal or provincial holidays
  holidays <- as.Date(c(
    "2016-02-15", # Family Day
    "2016-03-25", # Good Friday
    "2016-03-28", # Easter Monday (not statutory, optional)
    "2016-05-23", # Victoria Day
    "2016-07-01", # Canada Day
    "2016-08-01", # Saskatchewan Day (Civic Holiday)
    "2016-09-05", # Labour Day
    "2016-10-10", # Thanksgiving
    "2016-11-11"  # Remembrance Day
  ))
  
  if (date %in% holidays) return(FALSE)
  
  return(TRUE)
}

# Date ranges for 2016
date_ranges <- list(
  seq(as.Date("2016-09-01"), as.Date("2016-09-30"), by = "day"),
  seq(as.Date("2016-10-01"), as.Date("2016-10-31"), by = "day"),
  seq(as.Date("2016-11-01"), as.Date("2016-11-30"), by = "day"),
  seq(as.Date("2016-01-16"), as.Date("2016-01-31"), by = "day"),
  seq(as.Date("2016-02-01"), as.Date("2016-02-29"), by = "day"), # Leap year
  seq(as.Date("2016-03-01"), as.Date("2016-03-31"), by = "day"),
  seq(as.Date("2016-04-01"), as.Date("2016-04-30"), by = "day"),
  seq(as.Date("2016-12-01"), as.Date("2016-12-15"), by = "day"),
  seq(as.Date("2016-05-01"), as.Date("2016-05-31"), by = "day"),
  seq(as.Date("2016-06-01"), as.Date("2016-06-30"), by = "day"),
  seq(as.Date("2016-07-01"), as.Date("2016-07-31"), by = "day"),
  seq(as.Date("2016-08-01"), as.Date("2016-08-31"), by = "day")
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
        local_file <- file.path(date_folder, "Saskatoon.zip")
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


#############

# Base URL #
base_url <- "https://transitfeeds.com/p/the-city-of-regina/830"


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
        local_file <- file.path(date_folder, "Regina.zip")
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

