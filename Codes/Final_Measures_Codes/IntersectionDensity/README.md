# Intersection Density

This script calculates intersection density for dissemination areas (DAs) across Canadian provinces. As a key measure of walkability, intersection density is defined as the number of 3-way or more road intersections within a 1-kilometer buffer around each DA's population-weighted centroid.

---
## Data and Initial Setup

### Data Sources

The analysis uses three main datasets for a given census year:

* **DA Shapefile**: Contains the geographic boundaries for all Dissemination Areas.
    * **2011**: `lda_000b11a_e.shp`
    * **2016**: `lda_000b16a_e.shp`
    * **2021**: `lda_000b21a_e.shp`
* **Population-Weighted Centroids**: A pre-calculated file with a single point representing the population concentration for each DA. The file for the corresponding analysis year should be used.
    * **2011**: `DA_2011_hybrid_centroids_Canada.gpkg`
    * **2016**: `DA_2016_hybrid_centroids_Canada.gpkg`
    * **2021**: `DA_2021_hybrid_centroids_Canada.gpkg`
* **Road Network File (RNF)**: Contains road segments for all of Canada.
    * **2011**: `lrnf000r11a_e.shp`
    * **2016**: `lrnf000r16a_e.shp`
    * **2021**: `lrnf000r21a_e.shp`

---
## Core Methodology

The script processes data one province at a time.

### Preparing Buffers and Roads

* **Buffer Creation**: The script creates a 1-kilometer circular buffer around each DA's population-weighted centroid. This buffer serves as the analysis area for each DA.
* **Road Network Filtering**: The road network is filtered to remove limited-access highways and ramps, using class codes 10, 11, 12, and 13. This focuses the analysis on roads that are relevant to local walkability.

### Tiling and Intersection Analysis

To efficiently process large road networks, each province is divided into a grid of 10 km x 10 km tiles. The analysis is then performed on each tile independently.

For each tile, the script identifies true intersections by:
1.  **Noding the Network**: It finds all points where road lines cross or touch.
2.  **Splitting the Roads**: The road network is split at these points, breaking roads into smaller segments that connect at the nodes. This is known as "noding".
3.  **Counting Connections**: It counts how many road segments connect at each node.
4.  **Identifying 3+ Way Intersections**: Only nodes where three or more segments meet are considered valid intersections.

### Calculating Final Density

After all tiles are processed, the unique intersection points are combined.

* **Count Intersections**: The script counts the number of valid 3+ way intersections that fall within each DA's 1-km buffer.
* **Calculate Density**: The final density is calculated by dividing the intersection count by the buffer's area (π km²).

---
## Final Output

The results are combined for each DA and saved as a provincial Excel file. The output includes the following columns:

* **DAUID**: The unique identifier for the dissemination area.
* **intersection_count**: The total number of 3+ way intersections in the buffer.
* **intersection_density**: The number of intersections per square kilometer.
