# Population and Dwelling Densities [cite: 1]

[cite_start]This document outlines a high-precision method for calculating population and private dwelling densities[cite: 2]. [cite_start]The script calculates these densities within a 1-kilometer radius of a Dissemination Area's (DA) population-weighted centroid[cite: 3]. [cite_start]The core of this improved method is the use of census data at the Dissemination Block (DB) level, the smallest geographic unit for which census data is available[cite: 4]. [cite_start]This provides a much more granular and accurate spatial distribution of population and dwellings compared to using DA-level data[cite: 5].

## [cite_start]1. Data Sources [cite: 6]

[cite_start]The analysis relies on three key datasets[cite: 7]:

* [cite_start]**Census Data (at DB level)**: The script uses the `cancensus` package to retrieve population and private dwelling counts at the DB level from the Canadian Census[cite: 8]. [cite_start]To use the `cancensus` package, you need a valid API key, which you can obtain by signing up on the CensusMapper website (https://censusmapper.ca/users/sign_up)[cite: 9, 10].
* [cite_start]**Dissemination Block Shapefiles**: These are the geographic boundary files for the DBs, which are used to perform the spatial intersection[cite: 11].
* [cite_start]**Population-Weighted Centroids**: A pre-calculated file containing a single, population-weighted centroid for each DA[cite: 12]. [cite_start]These points serve as the center for the density calculation, accurately representing where people are concentrated within a DA[cite: 13].

## [cite_start]2. Methodology [cite: 14]

[cite_start]The calculation is performed for each province through a series of spatial operations[cite: 15].

### 2.1. [cite_start]Buffer Creation [cite: 16]

[cite_start]First, the script defines the analysis area for each DA[cite: 17]. [cite_start]It takes the pre-calculated population-weighted DA centroids and generates a 1-kilometer radius buffer around each one[cite: 18].

### 2.2. [cite_start]Areal Interpolation using Dissemination Blocks [cite: 19]

[cite_start]This is the central step of the analysis, where population and dwelling counts are allocated to each buffer[cite: 20].

* [cite_start]**Intersection**: For each 1-km DA buffer, the script identifies all of the smaller DB polygons that it intersects[cite: 21].
* [cite_start]**Proportional Allocation**: A DB may only partially fall within a buffer[cite: 22]. [cite_start]The script calculates the exact proportion of each intersecting DB's area that lies inside the buffer[cite: 23].
* [cite_start]**Estimation**: It then attributes the population and dwelling counts from that DB based on this area proportion[cite: 24]. [cite_start]For example, if 30% of a DB's area is inside the buffer, 30% of its population and 30% of its dwellings are assigned to that buffer[cite: 25].

### 2.3. [cite_start]Density Calculation [cite: 26]

[cite_start]For each DA buffer, the proportionally-allocated population and dwelling counts from all the intersecting DBs are summed up[cite: 27]. [cite_start]This gives a highly accurate estimate of the total population and total dwellings within the 1-km radius[cite: 28]. [cite_start]Finally, these total counts are divided by the buffer's area (which is $\pi \times (1 \text{ km})^2 \approx 3.14 \text{ km}^2$) to produce the final population density and dwelling density measures[cite: 29].

## [cite_start]3. Key Assumption [cite: 30]

[cite_start]The key assumption of this method is the uniform distribution of population and dwellings within each DB[cite: 31]. [cite_start]Because DBs represent a very small geographic area (often just a few city blocks), this assumption is far more reliable and leads to a more accurate density estimation than assuming uniform distribution across a much larger DA[cite: 32].
