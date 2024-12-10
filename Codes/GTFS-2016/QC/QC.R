
##QC##
#Agence métropolitaine de transport#

library(httr)

# Set working directory
setwd("V:/CanALE/Data/GTFS/QC")

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/129"

# Check for valid GTFS data availability
is_valid_date <- function(date) {
  # Exclude weekends (Saturday and Sunday)
  if (weekdays(date) %in% c("Saturday", "Sunday")) return(FALSE)
  
  # Exclude federal or provincial holidays
  holidays <- as.Date(c(
    "2016-08-01", # Civic Holiday
    "2016-09-05", # Labour Day
    "2016-10-10", # Thanksgiving
    "2016-11-11", # Remembrance Day
    "2016-02-15", # Family Day #In BC 2016-02-08
    "2016-03-25", # Good Friday
    "2016-03-28"  # Easter Monday
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
  seq(as.Date("2016-08-01"), as.Date("2016-08-31"), by = "day"),
  seq(as.Date("2016-12-01"), as.Date("2016-12-15"), by = "day")
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
        local_file <- file.path(date_folder, "AMT Express GTFS.zip")
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
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/128"

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
        local_file <- file.path(date_folder, "AMT Trains GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/130"


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
        local_file <- file.path(date_folder, "CIT Chambly-Richelieu-Carignan GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/132"


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
        local_file <- file.path(date_folder, "CIT des Laurentides GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/131"


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
        local_file <- file.path(date_folder, "CIT du Haut-Saint-Laurent GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/133"


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
        local_file <- file.path(date_folder, "CIT La Presquile GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/135"


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
        local_file <- file.path(date_folder, "CIT Le Richelain GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/136"


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
        local_file <- file.path(date_folder, "CIT Roussillon GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/137"


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
        local_file <- file.path(date_folder, "CIT Sorel-Varennes GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/138"


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
        local_file <- file.path(date_folder, "CIT Sud-ouest GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/139"


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
        local_file <- file.path(date_folder, "CIT Vallee-du-Richelieu GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/134"


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
        local_file <- file.path(date_folder, "CRT Lanaudiere GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/141"


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
        local_file <- file.path(date_folder, "MRC de Deux-Montagnes GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/140"


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
        local_file <- file.path(date_folder, "MRC de LAssomption GTFS.zip")
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

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/142"


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
        local_file <- file.path(date_folder, "MRC les Moulins GTFS.zip")
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
# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/1174"


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
        local_file <- file.path(date_folder, "Trains.zip")
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
# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/agence-metropolitaine-de-transport/143"


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
        local_file <- file.path(date_folder, "Ville de Sainte-Julie GTFS.zip")
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


############################################################

##Montreal##
#Société de transport de Montréal#

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/societe-de-transport-de-montreal/39"


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
        local_file <- file.path(date_folder, "STM GTFS.zip")
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

######

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/reseau-de-transport-de-la-capitale/40"


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
        local_file <- file.path(date_folder, "RTC_QCity.zip")
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

######

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/reseau-de-transport-de-longueuil/37"


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
        local_file <- file.path(date_folder, "RTL.zip")
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

######

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/reseau-de-transport-de-longueuil/38"


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
        local_file <- file.path(date_folder, "STL.zip")
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

######

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/societe-de-transport-de-levis/1173"


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
        local_file <- file.path(date_folder, "STDLevis.zip")
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

########

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/societe-de-transport-de-loutaouais/828"


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
        local_file <- file.path(date_folder, "STOGatineau.zip")
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


########

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/societe-de-transport-de-sherbrooke/827"


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
        local_file <- file.path(date_folder, "STDSherbrooke.zip")
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


########

# Base URL for Montreal Transit GTFS on TransitFeeds
base_url <- "https://transitfeeds.com/p/transcollines/1275"


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
        local_file <- file.path(date_folder, "Transcollines.zip")
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