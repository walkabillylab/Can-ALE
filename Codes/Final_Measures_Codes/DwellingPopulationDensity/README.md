# Population and Dwelling Densities

This document outlines a high-precision method for calculating population and private dwelling densities. The script calculates these densities within a 1-kilometer radius of a Dissemination Area's (DA) population-weighted centroid. The core of this improved method is the use of census data at the Dissemination Block (DB) level, the smallest geographic unit for which census data is available. This provides a much more granular and accurate spatial distribution of population and dwellings compared to using DA-level data.

## 1. Data Sources

The analysis relies on three key datasets:

* **Census Data (at DB level)**: The script uses the `cancensus` package to retrieve population and private dwelling counts at the DB level from the Canadian Census. To use the `cancensus` package, you need a valid API key, which you can obtain by signing up on the CensusMapper website (https://censusmapper.ca/users/sign_up).
* **Dissemination Block Shapefiles**: These are the geographic boundary files for the DBs, which are used to perform the spatial intersection.
* **Population-Weighted Centroids**: A pre-calculated file containing a single, population-weighted centroid for each DA. These points serve as the center for the density calculation, accurately representing where people are concentrated within a DA.

## 2. Methodology

The calculation is performed for each province through a series of spatial operations.

### 2.1. Buffer Creation

First, the script defines the analysis area for each DA. It takes the pre-calculated population-weighted DA centroids and generates a 1-kilometer radius buffer around each one.

### 2.2. Areal Interpolation using Dissemination Blocks

This is the central step of the analysis, where population and dwelling counts are allocated to each buffer.

* **Intersection**: For each 1-km DA buffer, the script identifies all of the smaller DB polygons that it intersects.
* **Proportional Allocation**: A DB may only partially fall within a buffer. The script calculates the exact proportion of each intersecting DB's area that lies inside the buffer.
* **Estimation**: It then attributes the population and dwelling counts from that DB based on this area proportion. For example, if 30% of a DB's area is inside the buffer, 30% of its population and 30% of its dwellings are assigned to that buffer.

### 2.3. Density Calculation

For each DA buffer, the proportionally-allocated population and dwelling counts from all the intersecting DBs are summed up. This gives a highly accurate estimate of the total population and total dwellings within the 1-km radius. Finally, these total counts are divided by the buffer's area (which is $\pi \times (1 \text{ km})^2 \approx 3.14 \text{ km}^2$) to produce the final population density and dwelling density measures.

## 3. Key Assumption

The key assumption of this method is the uniform distribution of population and dwellings within each DB. Because DBs represent a very small geographic area (often just a few city blocks), this assumption is far more reliable and leads to a more accurate density estimation than assuming uniform distribution across a much larger DA.
