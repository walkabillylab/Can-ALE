# Point of Interest (POI) Index

This document outlines the methodology for a script that calculates a weighted Point of Interest (POI) index for each dissemination area (DA). The script generates a comprehensive index reflecting the availability and accessibility of destinations relevant to active living environments. The final output is an Excel file that lists each DAUID with its raw POI count and the calculated weighted POI index.

---
## 1. Data Sources

The analysis uses three main types of spatial data:

* **Population-Weighted Centroids**:
    * 2011: `DA_2011_hybrid_centroids_Canada.gpkg`
    * 2016: `DA_2016_hybrid_centroids_Canada.gpkg`
    * 2021: `DA_2021_hybrid_centroids_Canada.gpkg`
* **DA Shapefile**: A file containing the geographic boundaries for all dissemination areas in Canada.
    * 2011: `lda_000b11a_e.shp`
    * 2016: `lda_000b16a_e.shp`
    * 2021: `lda_000b21a_e.shp`
* **POI Shapefiles**: Two separate OpenStreetMap (OSM) shapefiles are used:
    * One file contains POIs as points (e.g., `gis_osm_pois_free_1.shp`).
    * The other contains POIs as polygons (e.g., `gis_osm_pois_a_free_1.shp`).
    * POIs with "code" values not considered relevant to active living are filtered out. The codes that are kept are: 2423, 2725, 2424, 2951, 2961, 2734, 2422.

---
## 2. Spatial Data Preparation

* **Loading and Filtering DA Data**: The script loads the national DA boundary and population-weighted centroid shapefiles. It then filters both datasets to process the data one province at a time.
* **Coordinate Transformation**: All spatial data for a province are re-projected to the Statistics Canada Lambert projection (EPSG:3347). This projection is used to preserve accurate distance and area measurements in Canada.
* **Creating Buffers**: A circular buffer with a 1-kilometer radius is generated around each population-weighted centroid. These buffers serve as the catchment area for counting POIs for each DA.

---
## 3. Processing POI Data

* **Reading and Unifying POI Files**: The two POI files (points and polygons) are read and transformed into the same projection (EPSG:3347) as the DA data.
* **Geometry Conversion and Cleaning**: For the polygon POI file, the script corrects any geometry errors and then converts each polygon into its centroid. This ensures all POIs are represented as points.
* **Merging and Filtering**: The two POI datasets are merged into one. POIs with irrelevant OSM codes are then removed.

---
## 4. POI Weighting Methodology

Each POI is assigned a weight based on its category and its distance from the DA's centroid, rather than a simple count.

### 4.1 Category-Based Weights

POIs are given a base weight to reflect their importance to an active living environment. They are categorized into four tiers based on their OSM code:

* **Weight of 4**: Key destinations (e.g., Supermarkets, Park, Playground).
* **Weight of 3**: Important secondary destinations (e.g., University, Library, Cafe).
* **Weight of 2**: Other useful destinations (e.g., Cinema, Doctors, Hotel).
* **Weight of 1**: All other relevant POIs (default).

### 4.2 Distance-Decay Weights

A second weight is applied to account for proximity, where POIs closer to the DA centroid receive a higher weight. This is calculated with an exponential distance-decay function:

$W_{decay} = 1.0126 \times e^{-0.0013 \times d}$

Where `d` is the distance in meters from the POI to the DA's population-weighted centroid.

---
## 5. Spatial Join and Index Calculation

* **Spatial Join**: All POIs are spatially joined to the 1-km buffers to identify which DA each POI is associated with.
* **Final Weight Calculation**: A final weight is calculated for each POI within a buffer by multiplying its two weights:
    `Final Weight = Category Weight × Distance-Decay Weight`
* **Aggregation and Summarization**: The script groups all POIs by their DAUID and calculates two summary values:
    * `raw_poi_count`: The simple count of all POIs in the buffer.
    * `weighted_poi_index`: The sum of the `Final Weight` of all POIs in the buffer.
* **Final Output**: The results are joined back to the complete list of DAs for the province. This ensures that DAs with no POIs receive a value of 0. The final table is exported as an Excel file.
