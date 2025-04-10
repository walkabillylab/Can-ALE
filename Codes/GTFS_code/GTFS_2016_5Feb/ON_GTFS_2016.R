
##Ontario##
#Agence métropolitaine de transport#

library(httr)

# Set working directory
setwd("V:/CanALE/Data/GTFS/GTFS_2016/ON")

# Base URL for Ontario Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/barrie-transit/522"

# Check for valid GTFS data availability
is_valid_date <- function(date) {
  # Exclude weekends (Saturday and Sunday)
  if (weekdays(date) %in% c("Saturday", "Sunday")) return(FALSE)
  
  # Exclude federal or provincial holidays
  holidays <- as.Date(c(
    "2016-02-15", # Family Day
    "2016-03-25", # Good Friday
    "2016-03-28", # Easter Monday (not statutory, optional exclusion)
    "2016-05-23", # Victoria Day
    "2016-07-01", # Canada Day
    "2016-08-01", # Civic Holiday (optional exclusion)
    "2016-09-05", # Labour Day
    "2016-10-10"  # Thanksgiving
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
        local_file <- file.path(date_folder, "Barrie.zip")
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
base_url <- "https://transitfeeds.com/p/brampton-transit/35"


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
        local_file <- file.path(date_folder, "Brampton.zip")
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
base_url <- "https://transitfeeds.com/p/burlington-transit/294"


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
        local_file <- file.path(date_folder, "Burlington.zip")
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
base_url <- "https://transitfeeds.com/p/city-of-kingston/779"


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
        local_file <- file.path(date_folder, "Kingston.zip")
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
base_url <- "https://transitfeeds.com/p/city-of-windsor/778"


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
        local_file <- file.path(date_folder, "Windsor.zip")
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
base_url <- "https://transitfeeds.com/p/cornwall-transit/1223"


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
        local_file <- file.path(date_folder, "Cornwall.zip")
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
base_url <- "https://transitfeeds.com/p/durham-region-transit/642"


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
        local_file <- file.path(date_folder, "Durham.zip")
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
base_url <- "https://transitfeeds.com/p/go-transit/32"


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
        local_file <- file.path(date_folder, "Gotransit.zip")
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
base_url <- "https://transitfeeds.com/p/go-transit/543"


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
        local_file <- file.path(date_folder, "Gotransit-UpExpress.zip")
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
base_url <- "https://transitfeeds.com/p/grand-river-transit/203"


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
        local_file <- file.path(date_folder, "GRT.zip")
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
base_url <- "https://transitfeeds.com/p/greater-sudbury-transit/712"


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
        local_file <- file.path(date_folder, "Greater Sudbury Transit.zip")
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
base_url <- "https://transitfeeds.com/p/guelph-transit/53"


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
        local_file <- file.path(date_folder, "Guelph.zip")
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
base_url <- "https://transitfeeds.com/p/hamilton-street-railway/31"


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
        local_file <- file.path(date_folder, "Hamilton Street Railway.zip")
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
base_url <- "https://transitfeeds.com/p/london-transit-commission/831"


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
        local_file <- file.path(date_folder, "LTC.zip")
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
base_url <- "https://transitfeeds.com/p/milton-transit/929"


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
        local_file <- file.path(date_folder, "Milton.zip")
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
base_url <- "https://transitfeeds.com/p/miway/641"


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
        local_file <- file.path(date_folder, "MiWay.zip")
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
base_url <- "https://transitfeeds.com/p/oakville-transit/615"


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
        local_file <- file.path(date_folder, "Oakville.zip")
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
base_url <- "https://transitfeeds.com/p/oc-transpo/30"


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
        local_file <- file.path(date_folder, "OC Transpo.zip")
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
base_url <- "https://transitfeeds.com/p/regional-municipality-of-niagara/741"


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
        local_file <- file.path(date_folder, "Niagara.zip")
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
base_url <- "https://transitfeeds.com/p/thunder-bay-transit/201"


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
        local_file <- file.path(date_folder, "Thunder Bay.zip")
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
base_url <- "https://transitfeeds.com/p/ttc/33"


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
        local_file <- file.path(date_folder, "TTC.zip")
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
base_url <- "https://transitfeeds.com/p/wroute/1159"


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
        local_file <- file.path(date_folder, "wroute.zip")
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
base_url <- "https://transitfeeds.com/p/york-regional-transit/34"


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
        local_file <- file.path(date_folder, "YRT-Viva.zip")
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
