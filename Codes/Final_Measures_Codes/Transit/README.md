Transit Stop Density
This guide outlines the complete workflow for calculating transit stop density, from initial data acquisition to the final analysis. The process involves three main stages: downloading General Transit Feed Specification (GTFS) data, organizing the raw files, and then calculating the number of unique transit stops within a 1-kilometer buffer of each Dissemination Area's (DA) population-weighted centroid.

Step 1: Data Acquisition — Downloading GTFS Feeds
The first step is to automate the process of downloading GTFS data from the main sources (TransitFeeds website). Scripts are customized for each province, using URLs specific to the various transit agencies.
To ensure the data reflects typical ridership, a representative day is carefully selected based on the following criteria:
•	Exclusion of Atypical Days: Statutory holidays and weekends are excluded to avoid unusual transit usage patterns. Certain non-statutory holidays are also omitted, as service levels can vary.
•	Priority for High-Usage Days: The selection process prioritizes typical weekdays to capture standard commuting patterns.
The script iterates through a date range, checks each day against these criteria, and downloads the GTFS data for the first valid day found. The output of this step is a collection of raw GTFS files containing stops.txt files, which provide the geographic locations of transit stops.

Step 2: Data Processing — Organizing GTFS Files
Once downloaded, the raw GTFS files are processed and organized to prepare them for analysis.
•	Unzipping and Organization: The downloaded .zip files are unzipped and systematically stored in province-specific folders. Within each provincial folder, subdirectories are created for each transit agency, ensuring the data is clearly structured and easy to access.
•	Categorization by Area: The script also identifies transit agencies that operate within a Census Metropolitan Area (CMA). An agency is classified as a "CMA agency" if it serves any part of a CMA. This allows for future analyses that can differentiate between urban and non-urban transit systems.
The primary output of this stage is a set of cleanly organized stops.txt files, ready for the spatial analysis phase.

Step 3: Analysis — Calculating Transit Stop Counts per DA
This final stage uses the organized stops.txt files and geographic DA data to perform the final count.
3.1 Required Spatial Data
In addition to the processed GTFS files from Step 2, this stage requires two key spatial datasets:
•	DA Shapefile: A national shapefile containing the boundaries for all 2016 Dissemination Areas.
•	Population-Weighted Centroids: A pre-calculated file containing a single, population-weighted centroid for each DA, which more accurately represents where people live.
3.2 Provincial Data Preparation & Buffer Generation
The script loads the national DA boundary and centroid files. It processes the data one province at a time, filtering the datasets for the province being analyzed. All data is re-projected to the Statistics Canada Lambert projection (EPSG:3347) for accurate measurements.
Next, a 1-kilometer circular buffer is created around each population-weighted centroid. This buffer serves as the catchment area for counting transit stops.
3.3 Spatial Counting
The script aggregates all stops.txt files for the province into a single spatial layer. A spatial join is then performed to identify every transit stop that falls within each DA's 1-km buffer. Finally, it groups the results by each DA and counts the number of distinct transit stop IDs, which prevents any stop from being counted more than once.

Step 4: Final Output
The results are compiled into a final table. DAs that have no transit stops within their buffer are assigned a count of 0. This ensures a complete dataset for the province. The final table, containing each DAUID and its corresponding transit_stop_count, is exported as an Excel file for further use.

