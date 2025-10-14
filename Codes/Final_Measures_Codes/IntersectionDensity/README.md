# Intersection Density

This section outlines the method used for calculating intersection density of dissemination areas (DAs) across Canadian provinces. In this study, intersection density, a key measure of walkability, is defined as the number of 3-way or more road intersections within a 1-kilometer buffer around the population-weighted centroid of each DA.

## Data Sources

The analysis relies on three primary datasets for a given census year.

**DA Shapefile:** Contains the geographic boundaries for all Dissemination Areas.
* 2011: lda_000b11a_e.shp
* 2016: lda_000b16a_e.shp
* 2021: lda_000b21a_e.shp

**Population-Weighted Centroids:** A pre-calculated file with a single representative point for each DA, based on where the population is concentrated. The file corresponding to the analysis year should be used.
* 2011: DA_2011_hybrid_centroids_Canada.gpkg
* 2016: DA_2016_hybrid_centroids_Canada.gpkg
* 2021: DA_2021_hybrid_centroids_Canada.gpkg

**Road Network File (RNF):** Contains the road segments for all of Canada.
* 2011: lrnf000r11a_e.shp
* 2016: lrnf000r16a_e.shp
* 2021: lrnf000r21a_e.shp

## Methodology

The script processes data on one province at a time, following these steps:

### Step 1: Preparing Buffers and Roads

1. **Buffer Creation:** For each province, the script loads the pre-calculated population-weighted centroids for its DAs and creates a 1-kilometer circular buffer around each one. This buffer defines the area of analysis for each DA.

2. **Filtering the Road Network:** The provincial road network is filtered to exclude limited-access highways and ramps (class codes 10, 11, 12, and 13), focusing the analysis on roads relevant to local connectivity and walkability.

### Step 2: Tiling and Intersection Analysis

To handle large provincial road networks efficiently, the script divides the entire province into a grid of 10 km x 10 km tiles. The intersection analysis is then performed independently within each tile.

For each tile, the script performs a sophisticated process to identify true intersections:

1. **Node the Network:** It first finds all points where road lines cross or touch.
2. **Split the Roads:** The road network is then split at these intersection points, breaking down long roads into smaller segments that connect nodes. This process is known as "noding."
3. **Count Connections:** The script then counts how many of these new, smaller road segments connect at each node (endpoint).
4. **Identify 3+ Way Intersections:** Only nodes where three or more road segments meet are classified as valid intersections.

### Step 3: Calculating Final Density

After all tiles in a province are processed, the unique intersection points are combined.

1. **Count Intersections in Buffers:** The script counts how many of these valid 3+ way intersections fall within each DA's 1-km buffer.
2. **Calculate Density:** The final intersection density is calculated by dividing the total intersection count by the area of the buffer ($\pi r^{2}$ where $r=1km$ so the area is $\approx 3.14~km^{2}$).

The results are aggregated for each DA and saved as a provincial Excel file.
