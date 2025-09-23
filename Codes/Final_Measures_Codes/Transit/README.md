# [cite_start]Transit Stop Density [cite: 1]

[cite_start]This guide outlines the complete workflow for calculating transit stop density, from initial data acquisition to the final analysis. [cite: 2] [cite_start]The process involves three main stages: downloading General Transit Feed Specification (GTFS) data, organizing the raw files, and then calculating the number of unique transit stops within a 1-kilometer buffer of each Dissemination Area's (DA) population-weighted centroid. [cite: 3]

## [cite_start]Step 1: Data Acquisition — Downloading GTFS Feeds [cite: 4]

[cite_start]The first step is to automate the process of downloading GTFS data from the main sources (TransitFeeds website). [cite: 5] [cite_start]Scripts are customized for each province, using URLs specific to the various transit agencies. [cite: 6] [cite_start]To ensure the data reflects typical ridership, a representative day is carefully selected based on the following criteria: [cite: 7]

* [cite_start]**Exclusion of Atypical Days**: Statutory holidays and weekends are excluded to avoid unusual transit usage patterns. [cite: 8] [cite_start]Certain non-statutory holidays are also omitted, as service levels can vary. [cite: 9]
* [cite_start]**Priority for High-Usage Days**: The selection process prioritizes typical weekdays to capture standard commuting patterns. [cite: 10]

[cite_start]The script iterates through a date range, checks each day against these criteria, and downloads the GTFS data for the first valid day found. [cite: 11] [cite_start]The output of this step is a collection of raw GTFS files containing **stops.txt** files, which provide the geographic locations of transit stops. [cite: 12]

## [cite_start]Step 2: Data Processing — Organizing GTFS Files [cite: 13]

[cite_start]Once downloaded, the raw GTFS files are processed and organized to prepare them for analysis. [cite: 14]

* [cite_start]**Unzipping and Organization**: The downloaded .zip files are unzipped and systematically stored in province-specific folders. [cite: 15] [cite_start]Within each provincial folder, subdirectories are created for each transit agency, ensuring the data is clearly structured and easy to access. [cite: 16]
* [cite_start]**Categorization by Area**: The script also identifies transit agencies that operate within a Census Metropolitan Area (CMA). [cite: 17] [cite_start]An agency is classified as a "CMA agency" if it serves any part of a CMA. [cite: 18] [cite_start]This allows for future analyses that can differentiate between urban and non-urban transit systems. [cite: 19]

[cite_start]The primary output of this stage is a set of cleanly organized **stops.txt** files, ready for the spatial analysis phase. [cite: 20]

## [cite_start]Step 3: Analysis — Calculating Transit Stop Counts per DA [cite: 21]

[cite_start]This final stage uses the organized **stops.txt** files and geographic DA data to perform the final count. [cite: 22]

### [cite_start]3.1 Required Spatial Data [cite: 23]

[cite_start]In addition to the processed GTFS files from Step 2, this stage requires two key spatial datasets: [cite: 24]

* [cite_start]**DA Shapefile**: A national shapefile containing the boundaries for all 2016 Dissemination Areas. [cite: 25]
* [cite_start]**Population-Weighted Centroids**: A pre-calculated file containing a single, population-weighted centroid for each DA, which more accurately represents where people live. [cite: 26]

### [cite_start]3.2 Provincial Data Preparation & Buffer Generation [cite: 27]

[cite_start]The script loads the national DA boundary and centroid files. [cite: 28] [cite_start]It processes the data one province at a time, filtering the datasets for the province being analyzed. [cite: 29] [cite_start]All data is re-projected to the Statistics Canada Lambert projection (EPSG:3347) for accurate measurements. [cite: 30] [cite_start]Next, a **1-kilometer circular buffer** is created around each population-weighted centroid. [cite: 31] [cite_start]This buffer serves as the catchment area for counting transit stops. [cite: 32]

### [cite_start]3.3 Spatial Counting [cite: 33]

[cite_start]The script aggregates all **stops.txt** files for the province into a single spatial layer. [cite: 34] [cite_start]A spatial join is then performed to identify every transit stop that falls within each DA's 1-km buffer. [cite: 35] [cite_start]Finally, it groups the results by each DA and counts the number of distinct transit stop IDs, which prevents any stop from being counted more than once. [cite: 36]

## [cite_start]Step 4: Final Output [cite: 37]

[cite_start]The results are compiled into a final table. [cite: 38] [cite_start]DAs that have no transit stops within their buffer are assigned a count of 0. [cite: 38] [cite_start]This ensures a complete dataset for the province. [cite: 38] [cite_start]The final table, containing each DAUID and its corresponding transit_stop_count, is exported as an Excel file for further use. [cite: 39]
