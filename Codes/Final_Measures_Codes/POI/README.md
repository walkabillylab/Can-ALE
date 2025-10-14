# Point of Interest (POI)

This section outlines the method used for calculating a weighted Point of Interest (POI) index for each dissemination area (DA). The script generates a comprehensive index reflecting the availability and accessibility of destinations relevant to active living environments. The final output is an Excel file listing each DAUID alongside both a raw POI count and the calculated weighted POI index.

## Data Sources

The analysis uses three main types of data:

* **DA Shapefile:** A file containing the geographic boundaries for all dissemination areas in Canada.

  * 2011: `lda_000b11a_e.shp`

  * 2016: `lda_000b16a_e.shp`

  * 2021: `lda_000b21a_e.shp`

* **POI Shapefiles:** Two separate OpenStreetMap (OSM) shapefiles containing POIs:

  * One file contains POIs as points (e.g., `gis_osm_pois_free_1.shp`).

  * The other contains POIs as polygons (e.g., `gis_osm_pois_a_free_1.shp`).

* **Population-Weighted Centroids:**

  * 2011: `DA_2011_hybrid_centroids_Canada.gpkg`

  * 2016: `DA_2016_hybrid_centroids_Canada.gpkg`

  * 2021: `DA_2021_hybrid_centroids_Canada.gpkg`

## Methodology

### Step 1: Generating Buffers and Preparing POIs

* **Creating Buffers:** Using the filtered population-weighted centroids for the province, the script generates a circular buffer with a 1-kilometer radius around each centroid. These buffers define the catchment area for counting and weighting POIs for each DA.

* **POI Cleaning:** Some POI records are filtered out because their "code" values are not considered relevant to active living. POIs with the following codes are excluded: `"code" NOT IN (2423, 2725, 2424, 2951, 2961, 2734, 2422)`

### Step 2: Processing POI Data

* **Unifying POI Files:** For each province, the two POI files (points and polygons) are read and transformed into the same projection (EPSG:3347) to align with the DA data.

* **Geometry Conversion and Cleaning:** For the POI file containing polygons, the script converts each polygon feature into its centroid. This step ensures all POI features are uniformly represented as points.

* **Merging and Filtering:** The two processed POI datasets (original points and polygon-centroids) are merged into a single dataset. POIs with the irrelevant OSM codes listed in Step 1 are then removed.

### Step 3: POI Weighting

Instead of a simple count, each POI is assigned a final weight based on two factors: its category and its distance from the DA's population-weighted centroid.

#### Category-Based Weights

POIs are assigned a base weight to reflect their relative importance to creating an active living environment. POIs are categorized into four tiers based on their OSM code, with a higher weight indicating greater importance.

* **Weight of 4:** Key destinations (e.g., Supermarkets, Park, Playground).

* **Weight of 3:** Important secondary destinations (e.g., University, Library, Cafe).

* **Weight of 2:** Other useful destinations (e.g., Cinema, Doctors, Hotel).

* **Weight of 1:** All other relevant POIs (default).

#### Distance-Decay Weights

A second weight is applied to account for proximity. POIs closer to a DA's population-weighted centroid receive a higher weight than those farther away within the 1 km buffer. This is calculated using an exponential distance-decay function:

$W\_decay = 1.0126 \times e^{-0.0013 \times d}$

Where *d* is the distance in meters from the POI to the DA's population-weighted centroid.

### Step 4: Spatial Join and Index Calculation

* **Spatial Join:** All processed POIs are spatially joined to the 1-km buffers. This step identifies which DAs each POI is associated with.

* **Weight Calculation:** For each POI within a DA's buffer, a final weight is calculated by multiplying its two component weights:
  `Final Weight = Category Weight * Distance-Decay Weight`

* **Final Aggregation and Summarization:** The script groups all POIs by their associated DAUID. It then calculates two summary values for each DA:

  1. **raw_poi_count:** The simple count of all POIs within the buffer.

  2. **weighted_poi_index:** The sum of the `Final Weight` of all POIs within the buffer. This is the primary output metric.

### Final Output

The summary results are joined back to the complete list of DAs for the province. This ensures that DAs with no POIs in their buffer are included in the final report with their values set to 0. The final table is then exported as an Excel file for the province.
