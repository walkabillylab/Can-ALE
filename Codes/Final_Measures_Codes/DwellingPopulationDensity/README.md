# Population and Dwelling Densities

This section outlines the method used for calculating population and private dwelling densities. The script calculates these densities within a 1-kilometer radius of a Dissemination Area's (DA) population-weighted centroid. The core of this improved method is the use of census data at the Dissemination Block (DB) level, the smallest geographic unit for which census data is available. This approach provides a more granular and accurate spatial distribution of population and dwellings compared to methodologies that rely on DA-level data. The key assumption of this method is the uniform distribution of population and dwellings within each DB. Because DBs represent a very small geographic area (often just a few city blocks), this assumption is far more reliable and leads to a more accurate density estimation than assuming uniform distribution across a much larger DA.

---
## Data Sources:

The analysis relies on four key datasets:

* **Census Data (DB-Level):** Population and private dwelling counts at the DB level are retrieved from the Canadian Census using the `cancensus` package. A valid API key, which can be obtained by registering on the CensusMapper website (https://censusmapper.ca/users/sign_up), is required for this process.

* **DA Shapefile:** Contains geographic boundaries for all Dissemination Areas.
    * 2011: `lda_000b11a_e.shp`
    * 2016: `lda_000b16a_e.shp`
    * 2021: `lda_000b21a_e.shp`

* **DB Shapefile:** Contains geographic boundaries for all Dissemination Blocks.
    * 2011: `ldb_000b11a_e.shp`
    * 2016: `ldb_000b16a_e.shp`
    * 2021: `ldb_000b21a_e.shp`

* **Population-Weighted Centroids:** A pre-calculated file with a single representative point for each DA, based on where the population is concentrated. The file corresponding to the analysis year should be used.
    * 2011: `DA_2011_hybrid_centroids_Canada.gpkg`
    * 2016: `DA_2016_hybrid_centroids_Canada.gpkg`
    * 2021: `DA_2021_hybrid_centroids_Canada.gpkg`

---
## Methodology

The calculation is performed for each province through a series of spatial operations as described below.

### Step 1: Buffer Creation

First, the analysis area for each DA is defined. The script takes the pre-calculated population-weighted DA centroids and generates a 1-kilometer radius buffer around each point. This buffer specifies the specific area for which the density will be calculated.

### Step 2: Interpolation and Proportional Allocation

This is the central step of the analysis, where population and dwelling counts are allocated to each buffer. For each 1-km DA buffer, the script identifies all of the smaller DB polygons that it intersects. A DB may only partially fall within a buffer. The script calculates the exact proportion of each intersecting DB's area that lies inside the buffer. It then attributes the population and dwelling counts from that DB based on this area proportion. For example, if 30% of a DB's area is inside the buffer, 30% of its population and 30% of its dwellings are assigned to that buffer.

### Step 3: Density Calculation

For each DA buffer, the proportionally-allocated population and dwelling counts from all the intersecting DBs are summed up. This gives a highly accurate estimate of the total population and total dwellings within the 1-km radius. Finally, these total counts are divided by the buffer's area (which is $\pi\times(1~km)2\approx3.14~km2)$ to produce the final population density and dwelling density measures.
