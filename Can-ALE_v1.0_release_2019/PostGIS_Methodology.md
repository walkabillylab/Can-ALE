# Can-ALE POST GIS code

This code provides details on how the Can-ALE was calculated. It assumes you have all of the necessary data and software in the right places. 

## 1 Data import
### 1.1 CanMap RouteLogistics 2010 dataset

Create a PostgreSQL database and add the PostGIS extension

```
CREATE DATABASE phac_nross;
CREATE EXTENSION postgis;
```

Create a schema to store the dataset in PostgreSQL/PostGIS database 

```
CREATE SCHEMA canmap2010;
```

* Using ArcGIS, export all files from DMTI in shapefiles if not already in that format so that we can later import them in PostGIS. (NB: careful to split huge datasets into two parts to avoid hitting the 2GB limit of the dbf file format, such as CANrte; these datasets will be merged once imported into the DB)
* Use a batch file containing the following line to import all shapefiles into DB

```
for %%f in (*.shp) do shp2pgsql -I -D -s 4269 %%f canmap2010 .%%~nf | psql -d phac_nross -U postgres
```

* Update the _4269_ _canmap2010_ _phac_nross_ and _postgres_ parts to match local setup; to avoid typing each time the password for the user, a pgpass.conf should be added to the file system (see https://www.postgresql.org/docs/current/static/libpq- pgpass.html)
 
* Add index to some of the most used columns:

```
 CREATE INDEX ON canmap2010.canren (node_id); 
 CREATE INDEX ON canmap2010.canrte (fnode); 
 CREATE INDEX ON canmap2010.canrte (tnode);
 ```
 
 * Check if some other optimisations cannot be done, such as type coercion during the shapefile import, e.g. storing bigint as numeric or index on geometry transformation
 
```
 -- Type coercion
ALTER TABLE canmap2010.canren ALTER node_id TYPE bigint; --was imported as numeric(10,0)
ALTER TABLE canmap2010.canrte ALTER fnode TYPE bigint; --was imported as numeric
ALTER TABLE canmap2010.canrte ALTER tnode TYPE bigint; --was imported as numeric

 -- Index of geometry => geography type
```
 
### 1.2 UPDATE: CanMap Streetfiles 2006 dataset
* Given that Thomas will be using this dataset for the analyses, we proceed with the importation of the CANrds.shp and CANlur.shp files (which, by the way, are split by provinces)
* Create a schema to store the datasets in PostgreSQL/PostGIS database

```
CREATE SCHEMA streetfiles2006;
```

* Use a batch file with the following commands to import the __rds__ and __lur__ datasets:

```
shp2pgsql -p -I -D -s 4269 CANrds\ABrds.shp streetfiles2006.canrds | psql -d phac_nross -U postgres
for %%f in (CANrds\*.shp) do
shp2pgsql -a -D -s 4269 %%f streetfiles2006.canrds | psql -d phac_nross -U postgres
shp2pgsql -p –I -D -s 4269 CANrds\ABlur.shp streetfiles2006.canlur | psql -d phac_nross -U postgres
for %%f in (CANlur\*.shp) do
shp2pgsql -a -D -s 4269 %%f streetfiles2006.canlur | psql -d phac_nross -U postgres
````

* Create a new column geog to store the geography type corresponding to the geometry one + corresponding index:

```
ALTER TABLE streetfiles2006.canlur ADD COLUMN geog geography(MultiPolygon,4326);
ALTER TABLE streetfiles2006.canrds ADD COLUMN geog geography(MultiLineString,4326);
CREATE INDEX ON streetfiles2006.canlur USING gist (geog);
CREATE INDEX ON streetfiles2006.canrds USING gist (geog);
UPDATE streetfiles2006.canlur SET geog = ST_Transform(geom, 4326)::geography; UPDATE streetfiles2006.canrds SET geog = ST_Transform(geom, 4326)::geography;

-- add index on uniqueid and carto

CREATE INDEX ON streetfiles2006.canrds (uniqueid); CREATE INDEX ON streetfiles2006.canrds (carto);
```

### 1.3 Platinum Postal Code Suite (PPCS) 2011 dataset
* Create a schema to store the dataset in PostgreSQL/PostGIS database

```
CREATE SCHEMA ppcs2011;
```

* Imported shapefiles are (using the PostGIS shapefile and dbf loader plugin)

    * CANfsa.shp -to- `ppcs2011.canfsa`
    * All**ldu.shp -to- `ppcs2011.canldu(merged)`
    * CANlut.dbf -to- `ppcs2011.canlut`
    * CANmep.shp -to- `ppcs2011.canmep`
    * CANmep_retired -to- `ppcs2011.canmep_retired`
    
* Add index on CP fields to speedup querying:

```
CREATE INDEX ON ppcs2011.canldu (postalcode);
CREATE INDEX ON ppcs2011.canfsa (fsa);
CREATE INDEX ON ppcs2011.canlut (primary_pc);
CREATE INDEX ON ppcs2011.canlut (other_pc);
CREATE INDEX ON ppcs2011.canmep (postalcode);
CREATE INDEX ON ppcs2011.canmep_retired (postalcode);
```

* Add geog column

```
ALTER TABLE ppcs2011.canmep ADD COLUMN geog geography(Point,4326); 
CREATE INDEX ON ppcs2011.canmep USING gist (geog);
UPDATE ppcs2011.canmep SET geog = ST_Transform(geom, 4326)::geography;
```

* Replicate the same processing for canmep_retired

```
CREATE INDEX ON ppcs2011.canmep_retired (postalcode);
ALTER TABLE ppcs2011.canmep_retired ADD COLUMN geog geography(Point,4326); CREATE INDEX ON ppcs2011.canmep_retired USING gist (geog);
UPDATE ppcs2011.canmep_retired SET geog = ST_Transform(geom, 4326)::geography; CREATE INDEX ON ppcs2011.canmep_retired (postalcode);
```
* Create a view to concatenate all postal codes, current and retired 

```
 CREATE VIEW ppcs2011.canmep_all AS
  SELECT * FROM ppcs2011.canmep
  UNION
  SELECT * FROM ppcs2011.canmep_retired;
```

### 1.4 Census data 2006
* Create a schema to store the dataset in PostgreSQL/PostGIS database: CREATE SCHEMA census2006;
* Get full Canada coverage of the DA2006 (gad_000b06a_e.shp) -to- census2006.da_limits
* Add index on UID to speed up querying

```
CREATE INDEX ON census2006.da_limits (dauid); 
CREATE INDEX ON census2006.da_limits (csduid); 
CREATE INDEX ON census2006.da_limits (ccsuid); 
CREATE INDEX ON census2006.da_limits (cduid); 
CREATE INDEX ON census2006.da_limits (eruid); 
CREATE INDEX ON census2006.da_limits (pruid); 
CREATE INDEX ON census2006.da_limits (ctuid); 
CREATE INDEX ON census2006.da_limits (cmauid);
```

* Add geog field with corresponding spatial index

```
ALTER TABLE census2006.da_limits ADD COLUMN geog geography(MultiPolygon,4326); CREATE INDEX ON census2006.da_limits USING gist (geog);
UPDATE census2006.da_limits SET geog = ST_Transform(geom, 4326)::geography;
```

* UPDATE validtests.h_buffers SET geog = ST_Transform(geom32198, 4326)::geography;
* Import attributes about population and dwelling from *.ivt files, this requires
    1. selecting the variables of interest with Beyond 20/20
    2. exporting to CSV
    3. converting the CSV file to UTF-8 encoding
    4. cleaning up the invalid codes for null values (“-“) :
      * Age (123) and Sex (3) for the Population of Canada, Provinces, Territories, Census Divisions, Census Subdivisions and Dissemination Areas, 2006 Census - 100% Data | 97-551-XCB2006006.ivt -to- `da_population`

```
CREATE TABLE census2006.da_population
(
gid serial PRIMARY KEY,
   geography text,
  pop_total double precision,
  pop_male double precision,
  pop_female double precision
);
CREATE INDEX ON census2006.da_population (geography);
COPY census2006.da_population (geography, pop_total, pop_male, pop_female) FROM 'C:\_WORKSPACE\2017_PHAC_NancyRoss\census\da2006-population.csv' WITH (FORMAT CSV, HEADER TRUE);
```

* Household Type (11), Structural Type of Dwelling (10) and Housing Tenure (4) for Private Households of Canada, Provinces, Territories, Census Divisions, Census Subdivisions and Dissemination Areas, 2006 Census - 20% Sample Data | 97-554-XCB2006024.ivt -to- `da_dwelling`

```
CREATE TABLE census2006.da_dwelling
(
gid serial PRIMARY KEY,
geography text,
total_households double precision, 
  _family_households double precision, 
  __one_family_only_households double precision, 
  ___couple_family_households double precision, 
  ____without_children double precision, 
  ____with_children double precision, 
  ___lone_parent_family_households double precision, 
  __other_family_households double precision, 
  _non_family_households double precision, 
  __one_person_households double precision, 
  __two_or_more_person_households double precision)
);
CREATE INDEX ON census2006.da_dwelling (geography);
COPY census2006.da_dwelling (geography, total_households, 
  _family_households, 
  __one_family_only_households, 
  ___couple_family_households, 
  ____without_children, 
  ____with_children, 
  ___lone_parent_family_households, 
  __other_family_households, 
  _non_family_households, 
  __one_person_households,
 __two_or_more_person_households)
FROM 'C:\_WORKSPACE\2017_PHAC_NancyRoss\census\da2006-dwelling.csv' WITH (FORMAT CSV, HEADER TRUE);
```

### 1.5 Circular buffers around postal codes

* Most of the indicators are extracted over buffers around postal codes. We create a table to store those buffers, along with spatial indexes. The buffers themselves are created using ST_Buffer from the geography column of the main postal codes in table ppcs2011.canmep for the 2 radii 500m and 1km.

```
  CREATE TABLE public.circbuffers
(
gid serial primary key,
   postalcode text,
  radius double precision,
  geom geometry(Polygon, 4269),
  geog geography(Polygon, 4326)
);

CREATE INDEX ON public.circbuffers (postalcode); 
CREATE INDEX ON public.circbuffers (radius);
CREATE INDEX ON public.circbuffers USING gist (geom); 
CREATE INDEX ON public.circbuffers USING gist (geog);
```

* Then, buffers around each main postal code is created in both geographical systems

```
INSERT INTO public.circbuffers (postalcode, radius, geog)
  SELECT postalcode, 500, ST_Buffer(geog, 500) FROM ppcs2011.canmep_all WHERE
 sli=1;
INSERT INTO public.circbuffers (postalcode, radius, geog)
SELECT postalcode, 1000, ST_Buffer(geog, 1000) FROM ppcs2011.canmep_all
WHERE sli=1;
UPDATE public.circbuffers SET geom = ST_Transform(geog::geometry, 4269);
```

### 1.6 Network buffers around postal codes
* On the 10th of April, Thomas sends the network buffers (500m and 1000m) around all postal codes for the Montréal Island (respectively 47326 and 47324 polygons). These are imported into the table validtests.h_buffer schema of the pg DB with the PostGIS and DBF loader plugin. Then the geometry column projected into the EPSG 4269 projection and the geography columns are added to table.

```
ALTER TABLE validtests.h_buffers ADD COLUMN geom geometry(MultiPolygon,4269); ALTER TABLE validtests.h_buffers ADD COLUMN geog geography(MultiPolygon,4326);
CREATE INDEX ON validtests.h_buffers USING gist (geom); CREATE INDEX ON validtests.h_buffers USING gist (geog);
UPDATE validtests.h_buffers SET geom = ST_Transform(geom32198, 4269); UPDATE validtests.h_buffers SET geog = ST_Transform(geom32198, 4326)::geography;
```

* This table will be used for the validation of the various indicators ported to the pg DB from Thomas’s ArcGIS methodology.
* Eventually, a proper table is create to store the network buffers, which is built following the same data structure as the circular buffers

```
CREATE TABLE public.netbuffers
(
  gid serial primary key,
  postalcode text,
  radius double precision,
  geom geometry(MultiPolygon, 4269),
  geog geography(MultiPolygon, 4326)
);

CREATE INDEX ON public.netbuffers (postalcode); 
CREATE INDEX ON public.netbuffers (radius);
CREATE INDEX ON public.netbuffers USING gist (geom); 
CREATE INDEX ON public.netbuffers USING gist (geog);
```

* This table is temporary populated from the records stored in the validtests.h_buffers tables. Once the network buffers are computed for all postal codes, it will cover the whole Canada.

```
INSERT INTO public.netbuffers (postalcode, radius, geom, geog) 
 SELECT split_part(name, ' : ', 1) --postalcode
        ,tobreak::double precision --radius
        ,ST_MakeValid(geom)
        ,geog
 FROM validtests.h_buffers
 WHERE NOT ST_IsValid(geom)
 UNION
 SELECT split_part(name, ' : ', 1) --postalcode
     ,tobreak::double precision --radius
     ,geom
     ,geog
 FROM validtests.h_buffers
 WHERE ST_IsValid(geom);
```
* NB : geog field should be recreated from the validated geom field to avoid topology error later during the spatial queries; the previous query would then be followed by an update

```
UPDATE public.netbuffers SET geog = ST_Transform(geom, 4326)::geography;
```

### 1.7 List of imported and derived data
 TODO
 
## 2 Accuracy and performance pretests
### 2.1 Spatial index effect on query speed

* To test the performance of the spatial index on query speed, we set up a simple query to calculate the number of multiway intersection within each DA

```
 SELECT dauid, count(*)
FROM (SELECT * FROM census2006.da_limits WHERE cmauid='462' LIMIT 10) da,
   canmap2010.multiway_intersections mwi
WHERE ST_DWithin(da.geom, mwi.geom, 500)
GROUP BY dauid
ORDER BY dauid;
```

* Testing performance of ST_DWithin with two different strategies, but no true performance improvements from option 1 to option 2 with roughly 19min of query running
    1. `ST_DWithin(ST_transform(da_limits.geom,4326)::geography, ST_transform(multiway_intersections.geom,4326)::geography, 500)`
    2. `ST_DWithin(ST_transform(da_limits.geom,3348), ST_transform(multiway_intersections.geom,3348), 500)`, with GiST index on ST_transform(geom,3348)

* The third option is to create a new table, with projected geometries and associated spatial index. In that case, the same query issued on the newly created tables (da_limits_3348 & multiway_intersections_3348) returns the result in 60msec! This means all shapefiles should be projected and imported in the working database. This implies assessing first the effect of choosing one unique projection at the Canada scale (i.e. EPSG=3348 | NAD83(CSRS) / Statistics Canada Lambert) compared to larger scale projections (e.g. regional MTM projections).
* As a side effect, complex views involving geometries should be stored in a new table with spatial index on that geometry. A simple test with the same kind of query1 using the view canmap2010.multiway_intersections compared to another query using the very same information but stored a new table with built-in spatial index leads to 22.6sec for the query based on the view vs. 21msec for the other one.
* CONCLUSION: Intermediary views should be systematically stored as new tables with a spatial index to improve query performance.

### 2.2 Accuracy of chosen spatial reference

* Due to the size of the area of interest, which encompasses the whole Canada, we cannot use higher accuracy projections such as MTM zone ones (for Ontario or Québec). We need to find a good balance between the convenience of a projection at the Canada wide scale and the accuracy of such a projection. Based on Snyder exhaustive book2, a good candidate is the EPSG=3348 | NAD83 (CSRS) / Statistics Canada Lambert3, which is designed for small scale mapping and statistical analysis.
* As many indicators involve density measures, we start by looking how accurate the area of the DA polygons can be calculated with our candidate projection (NAD83 (CSRS) / Statistics Canada Lambert) vs. UTM projections as well as geodetic area calculation based on the geography type.
* We select 4 different UTM zones (10, 14, 18, 22), which cover Canada from West to East. DA that intersect these zones are reprojected into their corresponding zone (see query below for UTM zone 10N)

```
  INSERT INTO perftests.da_utm10
(dauid, cmauid, geom)
  SELECT dauid, cmauid,
ST_Transform(da.geom, utm.epsg)
  FROM census2006.da_limits da
  JOIN perftests.utm_zones utm ON
ST_Intersects(utm.geom, da.geom)
  WHERE zone_hemi='10,n';
```

* Then, we compare the resulting area of the DA projected 4in the various coordinate systems



![](Figure1.png)

1. Using ST_Intersects, this time.
2. Map Projections - A Working Manual, by John P. Snyder, U.S. Geological Survey Professional paper 1395, 1987.
3. http://spatialreference.org/ref/epsg/3348/
4. Although the geography type is not a projected geometry per se.

```
WITH utm AS (
  SELECT dauid, 10 zone_utm, ST_Area(geom) area_utm FROM perftests.da_utm10 UNION
  SELECT dauid, 14 zone_utm, ST_Area(geom) area_utm FROM perftests.da_utm14 UNION
  SELECT dauid, 18 zone_utm, ST_Area(geom) area_utm FROM perftests.da_utm18 UNION
  SELECT dauid, 22 zone_utm, ST_Area(geom) area_utm FROM perftests.da_utm22
)
SELECT dauid
  ,zone_utm
  ,ymin
  ,ymax
  ,area_geo
  ,area_lcc
 ,area_utm
 ,round(((area_geo-area_utm)/area_utm*100.0)::numeric,3) pct_err_geo_vs_utm 
 ,round(((area_lcc-area_utm)/area_utm*100.0)::numeric,3) pct_err_lcc_vs_utm
FROM (SELECT dauid
 ,round(ST_YMin(geom)::numeric,2) ymin 
 ,round(ST_YMax(geom)::numeric,2) ymax 
 ,ST_Area(ST_Transform(geom, 4326)::geography) area_geo FROM
census2006.da_limits) geo
NATURAL JOIN (SELECT dauid, ST_Area(geom) area_lcc FROM perftests.da_limits_3348) lcc
NATURAL JOIN utm
```

* The distribution of area error taking the UTM projected polygons as a reference is as follow (left is area based on geodetic calculation using the geography type, right is the area calculated from the geometry type projected into the Statistics Canada Lambert [EPSG=3348]):

![](Figure2.png)

* Geography type is clearly more accurate than the SCL projection regarding area calculation, and that’s confirmed by the [PostGIS documentation](http://postgis.net/docs/manual-2.3/using_postgis_dbmanagement.html#PostGIS_Geography). The remaining issue is the performance of queries involving the geography type.

### 2.3 Performance impact of the geography type
* Running the following query, we compare the various performances of the two scenarios: using the geometry type vs. the geography type.

```
SELECT dauid, count(*)
FROM perftests.da_limits_geog da
JOIN perftests.multiway_intersections_geog mwi ON ST_Intersects(da.geom, mwi.geom)
WHERE ST_Area(da.geog)< maxArea --change maxArea to filter out the largest polygons
GROUP BY dauid
  ORDER BY 1;
```

* Results

| | geometry type | geography type |
| --------------- | ------------- | -------------- |
| All DA polygons | 0:39:58 |1:24:00 |
| After getting rid of the 10% largest DA (37971764.9m2) | 0:00:57 | 0:20:07 |
After getting rid of the 5% largest DA (116968906.1m2) | 0:01:04 | 0:17:07 |
After getting rid of the 1% largest DA (892698627.5m2) | 0:00:40 | 0:28:21 |
After getting rid of the 0.1% largest DA (18197539720.4m2) |  0:00:51 | 0:34:05

* The geography type is clearly less optimized for queries involving spatial relationships. One option could be to rely on geography type for area and distance calculation and use the geometry type for topological analysis, such as polygon intersection and point in polygon analysis. The following query is used to evaluate the error introduce by using the geometry type for spatial relationships and switching to the geography type for distance and surface calculation

```
 WITH foo_geom AS (
SELECT dauid, fsa, ST_Area(ST_Transform(ST_Intersection(da.geom,
fsa.geom),4326)::geography) geom_area
FROM perftests.da_limits_geog da
JOIN perftests.canfsa_geog fsa ON ST_Intersects(da.geom, fsa.geom)
),
foo_geog AS (
SELECT dauid, fsa, ST_Area(ST_Intersection(da.geog, fsa.geog)) geog_area FROM perftests.da_limits_geog da
 JOIN perftests.canfsa_geog fsa ON ST_Intersects(da.geog, fsa.geog) )
SELECT *
  ,abs(geog_area - geom_area) err
FROM foo_geom
NATURAL JOIN foo_geog
ORDER BY 5 desc;
```

* Results (limited to Quebec province to speed up processing, which still took more than 11⁄2 day):

|  Statistique |  % |
| --------- | ----- |
|  N Valide |  18790 |
| N Manquant | 0 |
| Moyenne | 0,4552% | 
| Mediane | 0,0000% |
| Ecart type | 15,59759% |
| Minimum | 0,00% |
| Maximum | 1546,28% |

 * One issue that came up with the query above is that the original shapefile DA boundaries is not fully valid, with some polygons containing self-intersections; a problem that can be solved by using `ST_IsValid` and `ST_MakeValid` functions. The geography type does not exhibit these problems.

## 3 Topology tests

* The Interaction Land Use Mix requires a topological approach to be (easily) computed, as each boundary line needs to be aware of the its neighboring polygon characteristics. This section aims to explore the best way to setup the topology layers needed to complete the processing.
* We use a subset of the full land use dataset, centered on the H1Y postal code:

![](Figure3.png)

* Importing test data into a new schema using the shp2pg GUI

```
CREATE SCHEMA topotests;
COMMENT ON SCHEMA topotests
IS 'TEST - Exploring the topology approach for interaction measure';
CREATE TABLE topotests.lur_h1y
(
  gid serial PRIMARY KEY,
  category character varying(40),
  geom geometry(MultiPolygon,4269
);
```

### 3.1 Topology creation
* Topology extension activation

```
CREATE EXTENSION postgis_topology
  SCHEMA topology
  VERSION "2.2.2";
```

* Create a new topology layer (stored into its own schema) to store the test land use dataset

```
SELECT topology.CreateTopology('topo_lur_h1y', 4269);
```

* Create a distinct table to store the topology features for the test land use dataset

```
CREATE TABLE topotests.lur_h1y_topo (gid integer, category text);
```

* Add a topology layer to the newly created table – check the layer_id returned by the query, as it is needed later:

```
SELECT topology.AddTopoGeometryColumn('topo_lur_h1y', 'topotests', 'lur_h1y_topo', 'topogeom', 'MULTIPOLYGON');
```

* Populate the topology layer with land use polygons from the topotests.lur_h1y geometry – note that the function toTopoGeom requires the layer_id as a third argument

```
INSERT INTO topotests.lur_h1y_topo (gid, category, topogeom)
SELECT gid, category, topology.toTopoGeom(geom, 'topo_lur_h1y', 2) FROM topotests.lur_h1y;
```

* Check topology validity

```
 -- Get summary...
 SELECT topology.topologysummary('topo_lur_h1y'); /* In our test sample, this will return:
Topology topo_lur_h1y (id 1, SRID 4269, precision 0)
2533 nodes, 4537 edges, 2019 faces, 2005 topogeoms in 1 layers Layer 2, type Polygonal (3), 2005 topogeoms
 Deploy: topotests.lur_h1y_topo.topogeom
*/
-- ... and then list any invalid case

SELECT * FROM topology.ValidateTopology('topo_lur_h1y'); 

/* In our test sample, no problem has been detected */
```

### 3.2 Interaction Land Use Mix computation
* Once the topology layer is built from the original land use polygons, we can extract the edges that correspond to the interaction lines, that is which have on each side a different category group, and not an open area category. It must be noted that, following the original paper6 upon which this measure is based, the 7 land use classes are recoded into We use the following view to do so

```
CREATE VIEW topotests.interact_lum_h1y AS
WITH lur_h1y_topo_recode AS
( -- recode category to regroup them into 3 classes and discard Open Area
  SELECT gid, category,
         CASE category
             -- Recreation
            WHEN 'Parks and Recreational' THEN 'Recreation'
            WHEN 'Waterbody' THEN 'Recreation'
            -- Employment
            WHEN 'Resource and Industrial' THEN 'Employment' 
            WHEN 'Government and Institutional' THEN 'Employment' 
            WHEN 'Commercial' THEN 'Employment'
             -- Residential
             WHEN 'Residential' THEN 'Residential'
             ELSE null
        END recode_category
  FROM topotests.lur_h1y_topo
)
SELECT e.edge_id, e.geom,
CASE
WHEN llur.recode_category != rlur.recode_category THEN 1 ELSE 0
END keep
,llur.recode_category left_recode_category ,rlur.recode_category right_recode_category ,llur.category left_category ,rlur.category right_category
FROM topo_lur_h1y.edge e
LEFT JOIN topo_lur_h1y.relation lrel ON (lrel.element_id=e.left_face)
LEFT JOIN lur_h1y_topo_recode llur ON (llur.gid=lrel.topogeo_id)
LEFT JOIN topo_lur_h1y.relation rrel ON (rrel.element_id=e.right_face) 
LEFT JOIN lur_h1y_topo_recode rlur ON (rlur.gid=rrel.topogeo_id);
```
* The field keep = 1 is used to select boundary lines that match the criteria defined for the interaction land use mix. The resulting interaction lines appear in red in the figure below.

![](Figure4.png)

# 4 Walkability measures
## 4.1 Indicator list

The table below lists the walkability measures that will be implemented for this project

| Variable | Unit of Measurement | Definition | Derivation Sources | 
| -------- | ------------------- | ---------- | ------------------ |
| Three-way intersection density | ≥3-way intersection count per km2 | The number of ≥3-way intersections per unit area in the buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+)
| Four-way intersection density | ≥4-way intersection count per km2 | The number of ≥4-way intersections per unit area in the buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+)
| Local street network density | Kilometres of local roads per km2 | Total length (in kilometres) of local/ neighbourhood streets per square kilometre in each buffer | CanMap Street files:Postal code coordinates (PCCF+)
| Population Density | Population count per km2 | Total population in the dissemination area (DA) divided by the area of the DA in which the postal code is located | 2006 Census Boundary files:2006 Census population counts:Postal code coordinates (PCCF+) |
| Net population density | Population count per km2 of residential land use area | Total population in the dissemination area (DA) divided by the residential land use area in the DA in which the postal code is located | 2006 Census Boundary files:2006 Census population counts:Postal code coordinates (PCCF+):CanMap Street files |
| Dwelling density | Dwelling count per km2 | Total dwelling units in the dissemination area (DA) divided by the area of the DA in which the postal code is located | 2006 Census Boundary files:2006 Census population counts:Postal code coordinates (PCCF+) |
| Entropy: Land Use Mix | N/A | Degree of heterogenity in land uses contained in the buffer surrounding the postal code, calcuated using a commonly used entropy formula | CanMap Street files:Postal code coordinates (PCCF+) |
| Interaction: Land Use Mix | N/A | Length (in metres) of boundaries between different land use categories within each buffer | CanMap Street files:Postal code coordinates (PCCF+) | 
| Residential (land use) | % residential land use of all area in buffer | Total area attributed to residential land use, proportional to area of buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+) | 
| Commercial (land use) | % commercial land use of all area in buffer | Total area attributed to commercial land use, proportional to area of buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+) | 
| Government and Institutional (land use) | % government and institutional land use of all area in buffer | Total area attributed to government and institutional land use, proportional to area of buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+) |  
| Resource and Industrial (land use) | % resource and industrial land use of all area in buffer | Total area attributed to resource and industrial land use, proportional to area of buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+) | 
| Parks and Recreation (land use) | % parks and recreation land use of all area in buffer | Total area attributed to parks and recreation land use, proportional to area of buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+) | 
| Open space (land use) | % open space of all area in buffer | Total area attributed to open space, proportional to area of buffer surrounding a postal code | CanMap Street files:Postal code coordinates (PCCF+) | 
        

### 4.2 Naming convention
% open space of all area in buffer
Total area attributed to open space, proportional to area of buffer surrounding a postal code.
CanMap Street files
Postal code coordinates (PCCF+)
 Water (land use)
 % water of all area in buffer
 Total area attributed to water, proportional to area of buffer surrounding a postal code.
 CanMap Street files
Postal code coordinates (PCCF+)
* Each indicator can be computed using one of the three aggregation schemas:
1. At the postal code level: this is a direct reading of the indicator value (e.g. DA population density) for the
underlying unit within which the postal code is falling.
2. At the network buffer level: the indicator value is computed by taking the weighted average over the underlying
units which intersect with the network buffer centred on the postal code, the weight is the reference
population; two network buffer radii are used, 500m and 1km.
3. At the circular buffer level: same as for the network buffer method but with circular buffers instead; the two
same radii are used, 500m and 1km.
* Based on these three extraction methods, each view will be named according to the following scheme:
1. Direct extraction at the PC level  <indicator_name>_pc
2. Weighted average over network buffers<indicator_name>_netbuffer500&
<indicator_name>_netbuffer1000
3. Weighted average over network buffers  <indicator_name>_circbuffer500 &
<indicator_name>_circbuffer1000
* Due to the time required to extract the various indicators, it is suggested to export each indicators in a table named
according to the underlying view and suffixed with _tbl.
* A new DB schema is created to store the views and tables created to store the resulting indicators:
 2017-06-14 Methodology # B.Thierry 14

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
   CREATE SCHEMA walkability_measures;
4.3 Three-way and four-way intersection density
4.3.1 Data definition and production
*
  UPDATE: this was using the CANmap data, which include a CANren dataset with all the nodes of the street network.
 The Streetfile dataset does not contain this layer, hence we have to build it from the features in the CANrds layer
 (see below).
Create a new view to calculate the number of ways arriving to/leaving from each node in CANren. This supposes that fnode and tnode in table CANrte are correctly synchronized with node_id in CANren, which is not necessarily the case7.
             canmap2010.multiway_intersections
CREATE VIEW                                   AS
WITH node AS (
  SELECT gid, fnode node_id FROM canmap2010.canrte UNION ALL -- Include loops in the list
SELECT gid, tnode node_id FROM canmap2010.canrte
),
multiway AS (
  SELECT node_id, count(*) nb_way_intersect
  FROM node
  GROUP BY node_id
  HAVING count(*) >= 3
)
SELECT ren.*
  ,mw.nb_way_intersect
FROM canmap2010.canren ren
JOIN multiway mw USING(node_id)
             * UPDATE: we do not use this approach as it’s too slow for queries (no spatial index available to speed up queries). Create a new view to extract multiway intersections (3 ways and more) from CANrds dataset. This will be used for intersection density calculation:
    CREATE VIEW streetfiles2006.intersections AS WITH nodes AS (
SELECT gid rds_gid ,(ST_Dump(ST_Boundary(geom))).geom node
  FROM streetfiles2006.canrds
)
SELECT node, count(*) nb_ways
       FROM nodes
GROUP BY node
HAVING count(*) > 2;
   * Create a new table to store multiway intersections (3 ways and more) from CANrds dataset. This will be used for intersection density calculation. As specified by Thomas in his methodology, roads with CARTO = 1 are excluded from this set.
NB. A first version of the query was using the ST_Boundary function but it returns an empty geometry collection for multilines where the start point is the same as the end point (i.e. is a ring); we then have to switch for a
7 12 nodes from CANren are declared as not being an intersection (column intrsction=0) whereas the query returns multiway intersection.
2017-06-14 Methodology # B.Thierry 15
  
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
combination of functions ST_StartPoint & ST_EndPoint after transforming the Multinestring type into the simple Linestring type with the ST_MergeLine function.
 -- create table with spatial indexes
CREATE TABLE streetfiles2006.multiway_intersections (
  gid serial PRIMARY KEY,
  nb_ways smallint,
  geom geometry(Point, 4269),
  geog geography(Point, 4326)
);
CREATE INDEX ON streetfiles2006.multiway_intersections USING gist (geom); CREATE INDEX ON streetfiles2006.multiway_intersections USING gist (geog);
  -- Populate it || DO NOT USE: ST_Boundary returns an empty geometry for rings INSERT INTO streetfiles2006.multiway_intersections (nb_ways, geom, geog) WITH nodes AS (
SELECT gid rds_gid ,(ST_Dump(ST_Boundary(geom))).geom node
  FROM streetfiles2006.canrds
  WHERE carto >= 2
),
counts AS (
  SELECT node, count(*) nb_ways
  FROM nodes
  GROUP BY node
  HAVING count(*) > 2
)
SELECT nb_ways, node, ST_Transform(node, 4326)::geography FROM counts;
-- Populate it, first by converting the multilinestring to simple linestring, then taking the start and end points
INSERT INTO streetfiles2006.multiway_intersections (nb_ways, geom, geog) WITH nodes AS (
SELECT gid rds_gid ,ST_StartPoint(ST_LineMerge(geom)) node
  FROM streetfiles2006.canrds
                WHERE carto >= 2
  UNION ALL -- all is needed to keep both ends of rings
  SELECT gid rds_gid
        ,ST_EndPoint(ST_LineMerge(geom)) node
  FROM streetfiles2006.canrds
  WHERE carto >= 2
),
counts AS (
  SELECT node, count(*) nb_ways
  FROM nodes
  GROUP BY node
  HAVING count(*) > 2
 2017-06-14 Methodology # B.Thierry 16

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 )
SELECT nb_ways, node, ST_Transform(node, 4326)::geography FROM counts;
* Once the intersection layer is built, we can create the view three_and_four_way_intersection_density that extract the walkability measure:
    CREATE VIEW three_and_four_way_intersection_density AS
WITH netbuffers AS
( -- change definition/layer selection as needed to select the network buffers
  SELECT gid
        ,split_part(name, ' : ', 1) postalcode
        ,tobreak::double precision radius
        ,ST_Area(geog) buffer_area_m2
        ,geom
        ,geog
  FROM validtests.h_buffers -- change as needed
),
w3count AS
(
SELECT nb.gid, count(*)
FROM netbuffers nb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
nb.geom)
  WHERE nb_ways >= 3
  GROUP BY nb.gid
) ,
w4count as (
SELECT nb.gid, count(*)
FROM netbuffers nb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
nb.geom)
  WHERE nb_ways >= 4
  GROUP BY nb.gid
 )
SELECT nb.postalcode
,nb.radius
                     ,round(nb.buffer_area_m2::numeric, 1) netbuffer_area_m2
,round((COALESCE(w3.count, 0)/nb.buffer_area_m2*1000000)::numeric, 1) density_3way_intersections_per_km2
,round((COALESCE(w4.count, 0)/nb.buffer_area_m2*1000000)::numeric, 1) density_4way_intersections_per_km2
FROM netbuffers nb
LEFT JOIN w3count w3 USING (gid)
LEFT JOIN w4count w4 USING (gid)
ORDER BY 2,1;
         * This view produces the following columns :
o postalcode: postal code around which the network buffer is created
   2017-06-14 Methodology # B.Thierry 17

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
o radius : buffer radius (500m or 1000m)
o netbuffer_area_m2 : area of the network buffer, in square meters
o density_3way_intersections_per_km2 : density of 3-way and more intersections, expressed in number of
intersections per square kilometer
o density_4way_intersections_per_km2 : density of 4-way and more intersections, expressed in number of
intersections per square kilometer
4.3.2 Validity check
* We check the validity of this dataset (1) by comparing with the layer produced by Thomas on a distance based as well as (2) by counting the number of intersections found per network buffers (this validation is done on 1000m buffer only):
         -- 1st validation: Find the nearest node in streetfiles2006.multiway_intersections from each node in
 validtests.qc_id_3way_junctions; it should be 0 for all of them WITH knn AS (
  SELECT j.gid j_gid, j.count, j.geom
        ,foo.gid i_gid, foo.nb_ways, foo.dist_m
FROM validtests.qc_id_3way_junctions j -- layer produced by Thomas CROSS JOIN LATERAL
(SELECT gid, nb_ways
,ST_Distance(j.geog,i.geog) as dist_m FROM streetfiles2006.multiway_intersections i
     ORDER BY i.geom <-> j.geom LIMIT 3) As foo
),
closest AS (
  SELECT DISTINCT j_gid, count, geom
,first_value(i_gid) OVER (PARTITION BY j_gid ORDER BY dist_m) i_gid ,first_value(nb_ways) OVER (PARTITION BY j_gid ORDER BY dist_m) nb_ways ,first_value(dist_m) OVER (PARTITION BY j_gid ORDER BY dist_m) dist_m
FROM knn )
SELECT *
INTO validtests.qc_id_3way_junctions_closest FROM closest
ORDER BY dist_m DESC, j_gid;
-- 2nd validation: count the number of intersections in each buffer and compare to Thomas’s results
 WITH subset AS (
  SELECT * from validtests.h_buffers
  WHERE tobreak=1000
),
inter AS (
SELECT b.name, n.*
FROM streetfiles2006.multiway_intersections n JOIN subset b ON ST_Intersects(b.geom, n.geom)
),
counts3 AS (
SELECT name, count(*) pg3way_count
 2017-06-14 Methodology # B.Thierry 18

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 FROM inter
  GROUP BY name
),
counts4 AS (
  SELECT name, count(*) pg4way_count
  FROM inter
  WHERE nb_ways > 3
  GROUP BY name
)
SELECT b.name
  ,pg3way_count
  ,pg4way_count
  ,f3way_coun::int
  ,f4way_coun::int
 ,(pg3way_count - f3way_coun)::int test3way
,(pg4way_count - f4way_coun)::int test4way FROM subset b
LEFT JOIN counts3 USING (name)
LEFT JOIN counts4 USING (name)
LEFT JOIN validtests.results_mtl_id USING (name) ORDER BY 6
* The first validation leads to the following results for the distance (in meters) to the closest node:
* The second validation leads to the following stats (difference of intersection counts, for 1000m buffers only, missing values are due to NULL counts, which should be 0 instead):
  test3way
       Fréquence
   Pourcentage
   Pourcentage valide
   Pourcentage cumulé
 Valide
Manquant
  -1
  14
  ,0
  ,0
  ,0
  0
   47309
   100,0
   100,0
   100,0
  Total Système
 47323 1
 100,0 ,0
 100,0
  Total
  47324
  100,0
      test4way
        Fréquence
   Pourcentage
   Pourcentage valide
   Pourcentage cumulé
 Valide
Manquant
   -1
   4
   ,0
   ,0
   ,0
  0
   47055
   99,4
   100,0
   100,0
  Total Système
 47059 265
 99,4 ,6
 100,0
  2017-06-14 Methodology # B.Thierry 19

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 Total
  47324
  100,0
     In the tables above, missing values are due to NULL count in buffers, meaning no intersections have been found; they should be replace by 0 instead. The difference (-1) between Thomas and pg counts can be traced down to intersections being on or very close to the boundary of the buffer and considered inside by ArcGIS while pg find them outside.
* One note though, in the test above only considers the number of intersections found within each buffer. If we look at the density (i.e. number of intersections per unit of area), this would be another story as areas calculated by
Thomas are based on the Lambert Conformal Conic (EPSG=32198), which is not optimal for area calculation. When we compare with the area calculated from the geography type – which uses a geodetic calculation – we can see that the area from the projected polygons are systematically larger than the area from the unprojected ones.
(diff_geog = projected area – geodetic area, in meters)
4.3.3 [UPDATE 2017-05-25] Data extraction
* Update due to the new naming scheme and data organization.
* We still rely on the streetfiles2006.multiway_intersections table (see definition above) to precompute the intersections and their respective number of ways.
4.3.3.1 intersection_density_3way_pc
Non applicable (no reference spatial unit provided)
2017-06-14 Methodology # B.Thierry 20
              Three-way
intersection density
≥3-way intersection
count per km2
The number of ≥3-way intersections per unit area
in the buffer surrounding a postal code.
CanMap Street files
Postal code coordinates (PCCF+)
     Four-way intersection density
≥4-way intersection count per km2
The number of ≥4-way intersections per unit area in the buffer surrounding the postal code.
CanMap Street files
Postal code coordinates (PCCF+)
       
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
4.3.3.2 intersection_density_3way_netbuffer500 & intersection_density_3way_netbuffer1000
  CREATE VIEW                                                             AS
WITH w3count AS
(
SELECT nb.gid, count(*)
FROM (SELECT * FROM public.netbuffers WHERE radius = 500) nb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
nb.geom)
  WHERE nb_ways >= 3
  GROUP BY nb.gid
 )
SELECT nb.postalcode
,nb.radius
,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2
walkability_measures.intersection_density_3way_netbuffer500
 ,round((COALESCE(w3.count, 0)/ST_Area(nb.geog)*1000000)::numeric, 1) density_3way_intersections_per_km2
FROM (SELECT * FROM public.netbuffers WHERE radius = 500) nb
LEFT JOIN w3count w3 USING (gid);
CREATE VIEW walkability_measures.intersection_density_3way_netbuffer1000 AS WITH w3count AS
(
SELECT nb.gid, count(*)
FROM (SELECT * FROM public.netbuffers WHERE radius = 1000) nb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
nb.geom)
  WHERE nb_ways >= 3
  GROUP BY nb.gid
 )
SELECT nb.postalcode
,nb.radius
,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(w3.count, 0)/ST_Area(nb.geog)*1000000)::numeric, 1)
density_3way_intersections_per_km2
FROM (SELECT * FROM public.netbuffers WHERE radius = 1000) nb LEFT JOIN w3count w3 USING (gid);
 4.3.3.3 intersection_density_3way_circbuffer500 & intersection_density_3way_circbuffer1000
 CREATE VIEW
 walkability_measures.intersection_density_3way_circbuffer500
AS
 WITH w3count AS
(
SELECT cb.gid, count(*)
FROM (SELECT * FROM public.circbuffers WHERE radius = 500) cb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
cb.geom)
  WHERE nb_ways >= 3
  GROUP BY cb.gid
 )
SELECT cb.postalcode
,cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2
 2017-06-14 Methodology # B.Thierry 21

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ,round((COALESCE(w3.count, 0)/ST_Area(cb.geog)*1000000)::numeric, 1) density_3way_intersections_per_km2
FROM (SELECT * FROM public.circbuffers WHERE radius = 500) cb
LEFT JOIN w3count w3 USING (gid);
CREATE VIEW walkability_measures.intersection_density_3way_circbuffer1000 AS WITH w3count AS
(
SELECT cb.gid, count(*)
FROM (SELECT * FROM public.circbuffers WHERE radius = 1000) cb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
cb.geom)
  WHERE nb_ways >= 3
  GROUP BY cb.gid
   )
SELECT cb.postalcode
,cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(w3.count, 0)/ST_Area(cb.geog)*1000000)::numeric, 1)
density_3way_intersections_per_km2
FROM (SELECT * FROM public.circbuffers WHERE radius = 1000) cb LEFT JOIN w3count w3 USING (gid);
4.3.3.4 intersection_density_4way_pc
Non applicable (no reference spatial unit provided)
4.3.3.5 intersection_density_4way_netbuffer500 & intersection_density_4way_netbuffer1000
  CREATE VIEW AS WITH w4count AS
(
SELECT nb.gid, count(*)
FROM (SELECT * FROM public.netbuffers WHERE radius = 500) nb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
nb.geom)
  WHERE nb_ways >= 4
  GROUP BY nb.gid
 )
SELECT nb.postalcode
,nb.radius
walkability_measures.intersection_density_4way_netbuffer500
 ,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2
,round((COALESCE(w4.count, 0)/ST_Area(nb.geog)*1000000)::numeric, 1) density_4way_intersections_per_km2
FROM (SELECT * FROM public.netbuffers WHERE radius = 500) nb
LEFT JOIN w4count w4 USING (gid);
CREATE VIEW walkability_measures.intersection_density_4way_netbuffer1000 AS WITH w4count AS
(
SELECT nb.gid, count(*)
FROM (SELECT * FROM public.netbuffers WHERE radius = 1000) nb
  2017-06-14 Methodology # B.Thierry 22

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom, nb.geom)
  WHERE nb_ways >= 4
  GROUP BY nb.gid
 )
SELECT nb.postalcode
,nb.radius
,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(w4.count, 0)/ST_Area(nb.geog)*1000000)::numeric, 1)
density_4way_intersections_per_km2
FROM (SELECT * FROM public.netbuffers WHERE radius = 1000) nb LEFT JOIN w4count w4 USING (gid);
4.3.3.6 intersection_density_4way_circbuffer500 & intersection_density_4way_circbuffer1000
  CREATE VIEW                                                              AS
WITH w4count AS
(
SELECT cb.gid, count(*)
FROM (SELECT * FROM public.circbuffers WHERE radius = 500) cb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
cb.geom)
  WHERE nb_ways >= 4
  GROUP BY cb.gid
 )
SELECT cb.postalcode
,cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(w4.count, 0)/ST_Area(cb.geog)*1000000)::numeric, 1)
density_4way_intersections_per_km2
FROM (SELECT * FROM public.circbuffers WHERE radius = 500) cb LEFT JOIN w4count w4 USING (gid);
CREATE VIEW walkability_measures.intersection_density_4way_circbuffer1000 AS WITH w4count AS
(
SELECT cb.gid, count(*)
FROM (SELECT * FROM public.circbuffers WHERE radius = 1000) cb
JOIN streetfiles2006.multiway_intersections mi ON ST_Intersects(mi.geom,
cb.geom)
 walkability_measures.intersection_density_4way_circbuffer500
   WHERE nb_ways >= 4
  GROUP BY cb.gid
 )
SELECT cb.postalcode
,cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(w4.count, 0)/ST_Area(cb.geog)*1000000)::numeric, 1)
density_4way_intersections_per_km2
FROM (SELECT * FROM public.circbuffers WHERE radius = 1000) cb LEFT JOIN w4count w4 USING (gid);
 2017-06-14 Methodology # B.Thierry 23

4.3.4 Data dictionary
*
*
4.4
The four views for 3 way intersection density show the following variables:
o postalcode: postal code on which the buffer is centered
o radius: radius (500m / 1km) of the buffer
o buffer_area_m2: buffer area in sq. m.; circular buffer area are computed from the true shape, not the
mathematical formula
o density_3way_intersections_per_km2 : density of 3+ way intersections within the buffer, expressed as the
number of intersections with 3 or more ways per sq.km.
The four views for 4 way intersection density replace the density_3way_intersections_per_km2 by the following variable :
o density_4way_intersections_per_km2 : density of 4+ way intersections within the buffer, expressed as the number of intersections with 4 or more ways per sq.km.
Local street network density
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
4.4.1 Data definition and production
* The local street network density is using a subsample of the CANrds layer by limiting the analysis to roads with CARTO = 5. In order to avoid CTE optimization fences8, we create a view to extract local roads from the CANrds layer:
* Once the streetfiles2006.localroads utility view is built, we can extract the local road density (in km/km2) in the various buffers with the following view :
 CREATE OR REPLACE VIEW streetfiles2006.localroads AS SELECT * FROM streetfiles2006.canrds
WHERE carto = 5;
  CREATE VIEW                              AS
WITH pc AS
( -- Get main Postal Code (i.e. SLI=1)
  SELECT * FROM ppcs2011.canmep
  WHERE sli=1
),
circbuffers1km AS
( -- calculate the 1km buffer around postal code
  SELECT postalcode
        ,ST_Buffer(geog, 1000) geog
FROM pc ),
circbuffers500m AS
          local_street_network_density
 ( -- calculate the 500m buffer around postal code
  SELECT postalcode
        ,ST_Buffer(geog, 500) geog
  FROM pc
),
netbuffers AS
( -- Reformat netbuffers (provided by Thomas)
  SELECT gid
        ,split_part(name, ' : ', 1) postalcode
        ,tobreak::double precision radius
           8 https://blog.2ndquadrant.com/postgresql-ctes-are-optimization-fences/
2017-06-14 Methodology # B.Thierry 24
 
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
         ,ST_Area(geog) buffer_area_m2
        ,geom
        ,geog
  FROM validtests.h_buffers -- change as needed
),
roaddstynetbuf500m AS
(
  WITH foo AS (
        SELECT nb.postalcode, nb.buffer_area_m2
,ST_Length(ST_Intersection(rd.geog, nb.geog))/1000 road_length_km FROM (SELECT * FROM netbuffers WHERE radius=500) nb
JOIN streetfiles2006.localroads rd ON ST_Intersects(rd.geom, nb.geom)
  )
  SELECT postalcode
             ,round(buffer_area_m2::numeric, 1) netbuf500m_area_m2
,round((sum(road_length_km)/buffer_area_m2*1000000)::numeric,1) road_density_netbuf500m
FROM foo
  GROUP BY postalcode, buffer_area_m2
),
roaddstynetbuf1km AS
(
  WITH foo AS (
        SELECT nb.postalcode, nb.buffer_area_m2
,ST_Length(ST_Intersection(rd.geog, nb.geog))/1000 road_length_km FROM (SELECT * FROM netbuffers WHERE radius=1000) nb
JOIN streetfiles2006.localroads rd ON ST_Intersects(rd.geom, nb.geom)
  )
  SELECT postalcode
,round(buffer_area_m2::numeric, 1) netbuf1km_area_m2
,round((sum(road_length_km)/buffer_area_m2*1000000)::numeric,1) road_density_netbuf1km
FROM foo
  GROUP BY postalcode, buffer_area_m2
),
roaddstycircbuf500m AS
( -- road density over circular buffers around PC
WITH foo AS (
SELECT cb.postalcode, ST_Area(cb.geog) buffer_area_m2
                      ,ST_Length(ST_Intersection(rd.geog, cb.geog))/1000 road_length_km FROM circbuffers500m cb
JOIN pc USING (postalcode)
JOIN streetfiles2006.localroads rd ON ST_DWithin(pc.geog, rd.geog, 500)
  )
  SELECT postalcode
,round(buffer_area_m2::numeric,1) circbuf500m_area_m2
,round((sum(road_length_km)/buffer_area_m2*1000000)::numeric,1) road_density_circbuf500m
  FROM foo
  GROUP BY postalcode, buffer_area_m2
           2017-06-14 Methodology # B.Thierry 25

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ),
roaddstycircbuf1km AS
( -- road density over circular buffers around PC
WITH foo AS (
SELECT cb.postalcode, ST_Area(cb.geog) buffer_area_m2
,ST_Length(ST_Intersection(rd.geog, cb.geog))/1000 road_length_km FROM circbuffers1km cb
JOIN pc USING (postalcode)
JOIN streetfiles2006.localroads rd ON ST_DWithin(pc.geog, rd.geog,
1000) )
SELECT postalcode
,round(buffer_area_m2::numeric,1) circbuf1km_area_m2 ,round((sum(road_length_km)/buffer_area_m2*1000000)::numeric,1)
             road_density_circbuf1km
  FROM foo
  GROUP BY postalcode, buffer_area_m2
)
SELECT *
FROM (SELECT postalcode FROM pc) foo
LEFT JOIN roaddstynetbuf500m USING (postalcode) LEFT JOIN roaddstynetbuf1km USING (postalcode) LEFT JOIN roaddstycircbuf500m USING (postalcode) LEFT JOIN roaddstycircbuf1km USING (postalcode);
         * This view produces the following columns :
o postalcode: postal code around which the network buffer is created
o netbuf500m_area_m2: area of the 500m network buffer, in square meters
o road_density_netbuf500m: local street network density within the 500m network buffer, expressed in total
length of street (km) per square kilometer
o netbuf1km_area_m2: area of the 1km network buffer, in square meters
o road_density_netbuf1km: local street network density within the 1km network buffer, expressed in total
length of street (km) per square kilometer
o circbuf500m_area_m2: area of the 500m circular buffer, in square meters
o road_density_circbuf500m: local street network density within the 500m circular buffer, expressed in total
length of street (km) per square kilometer
o circbuf1km_area_m2: area of the 1km circular buffer, in square meters
o road_density_circbuf1km: local street network density within the 1km circular buffer, expressed in total
length of street (km) per square kilometer
4.4.2 [UPDATE 2017-05-25] Data extraction
* Update due to the new naming scheme and data organization.
* We still rely on the streetfiles2006.localroads view (see definition above) to reselect the local roads (and avoid CTE optimization fences).
2017-06-14 Methodology # B.Thierry 26
    Local street network density
    Kilometres of local roads per km2
   Total length (in kilometres) of local/ neighbourhood streets per square kilometre in each buffer
     CanMap Street files
Postal code coordinates (PCCF+)
  
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
4.4.2.1 local_street_density_pc
Non applicable (no reference spatial unit provided)
4.4.2.2 local_street_density_netbuffer500 & local_street_density_netbuffer1000
  CREATE VIEW                                                        AS
WITH foo AS (
SELECT nb.gid
,sum(ST_Length(ST_Intersection(rd.geog, nb.geog))) road_length
FROM (SELECT * FROM netbuffers WHERE radius=500) nb
JOIN streetfiles2006.localroads rd ON ST_Intersects(rd.geom, nb.geom) group by nb.gid
)
SELECT nb.postalcode
,nb.radius
walkability_measures.local_street_density_netbuffer500
 ,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2
,round((COALESCE(foo.road_length, 0)/ST_Area(nb.geog)*1000)::numeric, 2) road_density_km_by_km2
FROM (SELECT * FROM netbuffers WHERE radius = 500) nb
LEFT JOIN foo USING (gid);
CREATE VIEW walkability_measures.local_street_density_netbuffer1000 AS WITH foo AS (
SELECT nb.gid
,sum(ST_Length(ST_Intersection(rd.geog, nb.geog))) road_length
FROM (SELECT * FROM netbuffers WHERE radius=1000) nb
JOIN streetfiles2006.localroads rd ON ST_Intersects(rd.geom, nb.geom) group by nb.gid
)
SELECT nb.postalcode
,nb.radius
,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(foo.road_length, 0)/ST_Area(nb.geog)*1000)::numeric, 2)
road_density_km_by_km2
FROM (SELECT * FROM netbuffers WHERE radius = 1000) nb LEFT JOIN foo USING (gid);
 4.4.2.3 local_street_density_circbuffer500 & local_street_density_circbuffer1000
  walkability_measures.local_street_density_circbuffer500
CREATE VIEW                                                         AS
WITH foo AS (
 SELECT cb.gid
,sum(ST_Length(ST_Intersection(rd.geog, cb.geog))) road_length
FROM (SELECT * FROM circbuffers WHERE radius=500) cb
JOIN streetfiles2006.localroads rd ON ST_Intersects(rd.geom, cb.geom) group by cb.gid
)
SELECT cb.postalcode
,cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(foo.road_length, 0)/ST_Area(cb.geog)*1000)::numeric, 2)
road_density_km_by_km2
FROM (SELECT * FROM circbuffers WHERE radius = 500) cb
 2017-06-14 Methodology # B.Thierry 27

4.4.3 Data dictionary
*
4.5
4.5.1
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 LEFT JOIN foo USING (gid);
 CREATE VIEW walkability_measures.local_street_density_circbuffer1000 AS WITH foo AS (
SELECT cb.gid
,sum(ST_Length(ST_Intersection(rd.geog, cb.geog))) road_length
FROM (SELECT * FROM circbuffers WHERE radius=1000) cb
JOIN streetfiles2006.localroads rd ON ST_Intersects(rd.geom, cb.geom) group by cb.gid
)
SELECT cb.postalcode
,cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,round((COALESCE(foo.road_length, 0)/ST_Area(cb.geog)*1000)::numeric, 2)
 road_density_km_by_km2
FROM (SELECT * FROM circbuffers WHERE radius = 1000) cb LEFT JOIN foo USING (gid);
The two views for local road density show the following variables:
o postalcode: postal code on which the buffer is centered
o radius: radius (500m / 1km) of the buffer
o buffer_area_m2: buffer area in sq. m.; circular buffer area are computed from the true shape, not the
mathematical formula
o road_density_km_by_km2: total length of local roads within the buffer, expressed as a density in km per
sq.km.
Gross Population Density
Data definition and production
* This population density does not account for the residential areas, considering instead the whole DA area and a homogenous population across the DA.
* As specified by Thomas’s document, two options are presented to extract population density for each postal code:
o Option 1 relies on the simple computation of the population density in which the PC falls. o Option 2 computes the weighted population density over network and circular buffers.
* To avoid CTE optimization fences, we create a view to compute the population density for each DA:
 -- Create view to avoid CTE optimization fences
CREATE OR REPLACE VIEW                   AS
 census2006.da_pop
 SELECT l.dauid
     ,p.pop_total
,l.geom
,l.geog
FROM census2006.da_limits l
LEFT JOIN census2006.da_population p ON (p.geography=l.dauid);
* Once the census2006.da_pop utility view is built, we can extract the population density (in inhab./km2) in the various buffers with the following view:
  population_density
CREATE VIEW                    AS
WITH pc AS
   2017-06-14 Methodology # B.Thierry 28

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ( -- Get main Postal Code (i.e. SLI=1)
  SELECT * FROM ppcs2011.canmep
  WHERE sli=1
),
netbuffers AS
( -- Reformat netbuffers (provided by Thomas)
  SELECT gid
        ,split_part(name, ' : ', 1) postalcode
        ,tobreak::double precision radius
        ,ST_Area(geog) buffer_area_m2
        ,geom
        ,geog
  FROM validtests.h_buffers
),
             circbuffers1km AS
( -- calculate the 1km buffer around postal code
  SELECT postalcode
        ,ST_Buffer(geog, 1000) geog
FROM pc ),
circbuffers500m AS
( -- calculate the 500m buffer around postal code
  SELECT postalcode
        ,ST_Buffer(geog, 500) geog
FROM pc ),
dsty_option1 AS
( -- Density derived from the DA intersected by the PC point
SELECT pc.postalcode
,round(ST_Area(da.geog)::numeric, 1) da_area_m2 ,round((da.pop_total / ST_Area(da.geog) * 1000000)::numeric,1)
pop_density_km2_option1
  FROM pc
JOIN census2006.da_pop da ON St_Intersects(da.geom, pc.geom) ),
dsty_option2_netbuf1km AS
( -- weighted density of pop over netbuffers around PC
  WITH foo AS (
        SELECT nb.postalcode, nb.buffer_area_m2
                       ,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, nb.geog)) / ST_Area(da.geog) pop_subset
FROM (SELECT * FROM netbuffers WHERE radius=1000) nb
JOIN census2006.da_pop da ON ST_Intersects(da.geom, nb.geom) )
SELECT postalcode
,round(buffer_area_m2::numeric, 1) netbuf1km_area_m2 ,round((sum(pop_subset)/buffer_area_m2*1000000)::numeric,1)
pop_density_km2_option2_netbuf1km
  FROM foo
           2017-06-14 Methodology # B.Thierry 29

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
   GROUP BY postalcode, buffer_area_m2
),
dsty_option2_netbuf500m AS
( -- weighted density of pop over netbuffers around PC
  WITH foo AS (
        SELECT nb.postalcode, nb.buffer_area_m2
,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, nb.geog)) / ST_Area(da.geog) pop_subset
FROM (SELECT * FROM netbuffers WHERE radius=500) nb
JOIN census2006.da_pop da ON ST_Intersects(da.geom, nb.geom) )
SELECT postalcode
,round(buffer_area_m2::numeric, 1) netbuf500m_area_m2
             ,round((sum(pop_subset)/buffer_area_m2*1000000)::numeric,1) pop_density_km2_option2_netbuf500m
FROM foo
  GROUP BY postalcode, buffer_area_m2
),
dsty_option2_circbuf1km AS
( -- weighted density of pop over circular buffers around PC
WITH foo AS (
SELECT cb.postalcode, ST_Area(cb.geog) buffer_area_m2
,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, cb.geog)) / ST_Area(da.geog) pop_subset
FROM circbuffers1km cb
JOIN pc USING (postalcode)
JOIN census2006.da_pop da ON ST_DWithin(pc.geog, da.geog, 1000)
  )
  SELECT postalcode
,round(buffer_area_m2::numeric,1) circbuf1km_area_m2
,round((sum(pop_subset)/buffer_area_m2*1000000)::numeric,1) pop_density_km2_option2_circbuf1km
FROM foo
  GROUP BY postalcode, buffer_area_m2
),
dsty_option2_circbuf500m AS
( -- weighted density of pop over circular buffers around PC
                       WITH foo AS (
SELECT cb.postalcode, ST_Area(cb.geog) buffer_area_m2
,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, cb.geog)) / ST_Area(da.geog) pop_subset
FROM circbuffers500m cb
JOIN pc USING (postalcode)
JOIN census2006.da_pop da ON ST_DWithin(pc.geog, da.geog, 500)
  )
  SELECT postalcode
         ,round(buffer_area_m2::numeric,1) circbuf500m_area_m2
  2017-06-14 Methodology # B.Thierry 30

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ,round((sum(pop_subset)/buffer_area_m2*1000000)::numeric,1) pop_density_km2_option2_circbuf500m
FROM foo
  GROUP BY postalcode, buffer_area_m2
)
SELECT *
FROM dsty_option1
NATURAL JOIN dsty_option2_netbuf500m
NATURAL JOIN dsty_option2_netbuf1km
NATURAL JOIN dsty_option2_circbuf500m
NATURAL JOIN dsty_option2_circbuf1km
ORDER BY 1;
           * This view produces the following columns :
o postalcode: postal code around which the network buffer is created
o da_area_m2 : area of the dissemination area where the PC falls, in square meters
o pop_density_km2_option1 : population density according to option 1, i.e. pop density of the DA where the
PC falls, in inhabitants/sq.km.
o netbuf500m_area_m2: area of the 500m network buffer, in square meters
o pop_density_km2_option2_netbuf500m:weightedpopulationdensityaccordingtooption2overnetwork
buffers with 500m radius, in inhabitants/sq.km.
o netbuf1km_area_m2: area of the 1km network buffer, in square meters
o pop_density_km2_option2_netbuf1km:weightedpopulationdensityaccordingtooption2overnetwork
buffers with 1km radius, in inhabitants/sq.km.
o circbuf500m_area_m2: area of the 500m circular buffer, in square meters
o pop_density_km2_option2_circbuf500m:weightedpopulationdensityaccordingtooption2overcircular
buffers with 500m radius, in inhabitants/sq.km.
o circbuf1km_area_m2: area of the 1km circular buffer, in square meters
o pop_density_km2_option2_circbuf1km: weighted population density according to option 2 over circular
buffers with 1km radius, in inhabitants/sq.km
4.5.2 [UPDATE 2017-05-25] Data extraction
* Update due to the new naming scheme and data organization.
* We still rely on the census2006.da_pop view (see definition above) to join population count to DA boundaries (and avoid CTE optimization fences).
4.5.2.1 population_density_pc
* This view corresponds to the option #1, as defined by Thomas
* DA with no population count have a NoData value (-7)
   Population Density
   Population count per km2
  Total population in the dissemination area (DA) divided by the area of the DA in which the postal code is located.
  2006 Census Boundary files 2006 Census population counts Postal code coordinates (PCCF+)
     CREATE VIEW                                            AS
SELECT pc.postalcode
,dauid
,round(ST_Area(da.geog)::numeric, 1) da_area_m2
walkability_measures.population_density_pc
 2017-06-14 Methodology # B.Thierry 31

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ,COALESCE(round((da.pop_total / ST_Area(da.geog) * 1000000)::numeric,1), -7) population_density_km2
FROM (SELECT * FROM ppcs2011.canmep_all WHERE sli=1) pc -- Get main Postal Code (i.e. SLI=1)
LEFT JOIN census2006.da_pop da ON St_Intersects(da.geom, pc.geom);
4.5.2.2 population_density_netbuf500 & population_density_netbuf1000
* This view corresponds to the option #2, as defined by Thomas
* NB: DA with no population count will lead to a NoData value (-7) for the weighted density.
  CREATE VIEW                                                      AS
WITH foo AS (
  SELECT nb.gid
        ,da.dauid
walkability_measures.population_density_netbuffer500
 ,da.pop_total * ST_Area(St_Intersection(da.geog, nb.geog)) / ST_Area(da.geog) pop_subset
FROM (SELECT * FROM netbuffers WHERE radius=500) nb
LEFT JOIN census2006.da_pop da ON ST_Intersects(da.geom, nb.geom) ),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct nb.gid
        ,coalesce(da.nodata, false) nodata
from (SELECT * FROM netbuffers WHERE radius=500) nb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(nb.geom, da.geom)
)
SELECT nb.postalcode, nb.radius
,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2 ,string_agg(distinct dauid, ';' order by dauid) dauids ,CASE nodata
WHEN false THEN round((sum(pop_subset)/ST_Area(nb.geog) * 1000000)::numeric,1)
        ELSE -7
  END weighted_pop_density_km2
FROM (SELECT * FROM netbuffers WHERE radius=500) nb LEFT JOIN foo USING (gid)
JOIN discard_nodata USING (gid)
GROUP BY nb.postalcode, nb.radius, nb.geog, nodata;
  CREATE VIEW walkability_measures.population_density_netbuffer1000 AS WITH foo AS (
  SELECT nb.gid
        ,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, nb.geog)) / ST_Area(da.geog) pop_subset
FROM (SELECT * FROM netbuffers WHERE radius=1000) nb
LEFT JOIN census2006.da_pop da ON ST_Intersects(da.geom, nb.geom) ),
discard_nodata as
( -- Find buffers that intersect DA with no population value
 2017-06-14 Methodology # B.Thierry 32

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
   select distinct nb.gid
        ,coalesce(da.nodata, false) nodata
from (SELECT * FROM netbuffers WHERE radius=1000) nb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(nb.geom, da.geom)
)
SELECT nb.postalcode, nb.radius
,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2 ,string_agg(distinct dauid, ';' order by dauid) dauids ,CASE nodata
WHEN false THEN round((sum(pop_subset)/ST_Area(nb.geog) * 1000000)::numeric,1)
        ELSE -7
  END weighted_pop_density_km2
 FROM (SELECT * FROM netbuffers WHERE radius=1000) nb LEFT JOIN foo USING (gid)
JOIN discard_nodata USING (gid)
GROUP BY nb.postalcode, nb.radius, nb.geog, nodata;
4.5.2.3 population_density_circbuf500 & population_density_circbuf1000
* This view corresponds to the option #2, as defined by Thomas
* NB: DA with no population count will lead to a NoData value (-7) for the weighted density.
  CREATE VIEW                                                       AS
WITH foo AS (
  SELECT cb.gid
        ,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, cb.geog)) / ST_Area(da.geog) pop_subset
FROM (SELECT * FROM circbuffers WHERE radius=500) cb
LEFT JOIN census2006.da_pop da ON ST_Intersects(da.geom, cb.geom) ),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct cb.gid
        ,coalesce(da.nodata, false) nodata
from (SELECT * FROM circbuffers WHERE radius=500) cb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(cb.geom, da.geom)
walkability_measures.population_density_circbuffer500
 )
SELECT cb.postalcode, cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,string_agg(distinct dauid, ';' order by dauid) dauids ,CASE nodata
WHEN false THEN round((sum(pop_subset)/ST_Area(cb.geog) * 1000000)::numeric,1)
        ELSE -7
  END weighted_pop_density_km2
FROM (SELECT * FROM circbuffers WHERE radius=500) cb LEFT JOIN foo USING (gid)
JOIN discard_nodata USING (gid)
 2017-06-14 Methodology # B.Thierry 33

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 GROUP BY cb.postalcode, cb.radius, cb.geog, nodata;
 CREATE VIEW walkability_measures.population_density_circbuffer1000 AS WITH foo AS (
  SELECT cb.gid
        ,da.dauid
,da.pop_total * ST_Area(St_Intersection(da.geog, cb.geog)) / ST_Area(da.geog) pop_subset
FROM (SELECT * FROM circbuffers WHERE radius=1000) cb
LEFT JOIN census2006.da_pop da ON ST_Intersects(da.geom, cb.geom) ),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct cb.gid
 ,coalesce(da.nodata, false) nodata
from (SELECT * FROM circbuffers WHERE radius=1000) cb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total
is null) da ON ST_Intersects(cb.geom, da.geom) )
SELECT cb.postalcode, cb.radius
,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2 ,string_agg(distinct dauid, ';' order by dauid) dauids ,CASE nodata
WHEN false THEN round((sum(pop_subset)/ST_Area(cb.geog) * 1000000)::numeric,1)
        ELSE -7
  END weighted_pop_density_km2
FROM (SELECT * FROM circbuffers WHERE radius=1000) cb LEFT JOIN foo USING (gid)
JOIN discard_nodata USING (gid)
GROUP BY cb.postalcode, cb.radius, cb.geog, nodata;
4.5.3 Data dictionary
* The view for gross population density at postal code location shows the following variables: o postalcode:postalcodeofinterest
o dauid: dissemination area (DA) unique ID where the postal code falls
o da_area_m2:DAareainsq.m.
o population_density_km2: population density within DA where the postal code falls, expressed in inhabitants per sq.km.
* The four views for gross population density in buffers show the following variables:
o postalcode: postal code on which the buffer is centered
o radius: radius (500m / 1km) of the buffer
o dauids: list of dissemination area unique IDs that intersect with the buffer
o buffer_area_m2: buffer area in sq. m.; circular buffer area are computed from the true shape, not the
mathematical formula
o weighted_pop_density_km2: weighted average of the population density within buffer, expressed in
inhabitants per sq.km.
 2017-06-14
Methodology # B.Thierry 34

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
4.6 Net Population Density
4.6.1 Data extraction
* This population density accounts for the residential areas, population is supposed to be living only in the residential parts of each DA.
* As specified by Thomas’s document, two options are presented to extract population density for each postal code:
o Option 1 relies on the simple computation of the population density in which the PC falls. o Option2computestheweightedpopulationdensityovernetworkandcircularbuffers.
4.6.1.1 net_pop_density_pc
* This view corresponds to the option #1, as defined by Thomas
* DA with no population count have a NoData value (-7)
    Net population density
    Population count per km2 of residential land use area
   Total population in the dissemination area (DA) divided by the residential land use area in the DA in which the postal code is located.
  2006 Census Boundary files 2006 Census population counts CanMap Street files
Postal code coordinates (PCCF+)
      CREATE VIEW AS
WITH dar AS
( -- Limit population to residential areas, unless no residential area exists
-- within DA, in which case the whole DA is considered instead.
-- We add a field [no_residential] to flag DA without residential areas
  SELECT dauid
        ,pop_total
        ,CASE coalesce(lur.gid, -1)
             WHEN -1 THEN 1
             ELSE 0
        END no_residential
        ,CASE COALESCE(lur.gid, -1)
             WHEN -1 THEN da.geom
             ELSE ST_Intersection(lur.geom, da.geom)
        END geom
  FROM census2006.da_pop da
LEFT JOIN (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(da.geom, lur.geom) )
walkability_measures.net_pop_density_pc
 -- Compute net population density
SELECT pc.postalcode
,dauid
,sum(no_residential) approximated ,round((sum(ST_Area(ST_Transform(dar.geom, 4326)::geography)))::numeric, 1)
resid_da_area_m2
,COALESCE(round((1000000 * pop_total / sum(ST_Area(ST_Transform(dar.geom,
4326)::geography)))::numeric,1), -7) net_pop_density_km2
FROM (SELECT * FROM ppcs2011.canmep_all WHERE sli=1) pc -- Get main Postal Code (i.e. SLI=1)
LEFT JOIN dar ON St_Intersects(dar.geom, pc.geom)
GROUP by pc.postalcode,dauid,pop_total;
 2017-06-14 Methodology # B.Thierry 35

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
4.6.1.2 net_pop_density_netbuf500 & net_pop_density_netbuf1000
* This view corresponds to the option #2, as defined by Thomas
* Buffers with no residential area are set to a null (0) net density
* Buffers that intersect DA with no population count have a NoData value (-7)
  CREATE VIEW AS
WITH dar AS
( -- Limit population to residential areas, unless no residential area exists
-- within DA, in which case the whole DA is considered instead.
-- We add a field [no_residential] to flag DA without residential areas
  SELECT dauid
        ,pop_total
        ,lur.gid::text lur_id
        ,CASE coalesce(lur.gid, -1)
walkability_measures.net_pop_density_netbuf500
 WHEN -1 THEN 1
             ELSE 0
        END no_residential
        ,CASE COALESCE(lur.gid, -1)
             WHEN -1 THEN da.geom
             ELSE ST_Intersection(lur.geom, da.geom)
        END geom
  FROM census2006.da_pop da
LEFT JOIN (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(da.geom, lur.geom) ),
dar_netpop AS
( -- Compute net population density.
SELECT dauid
,pop_total / sum(ST_Area(ST_Transform(geom, 4326)::geography))
pop_lur_dsty
,sum(ST_Area(ST_Transform(geom, 4326)::geography)) lur_area_within_da
FROM dar
  GROUP by dauid, pop_total
),
nb_resid AS
( -- Compute residential area within buffer.
select nb.gid
,sum(ST_Area(ST_Intersection(nb.geog, lur.geog))) lur_area_within_buf
from (SELECT * FROM netbuffers WHERE radius=500) nb
 left join (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(nb.geom, lur.geom)
  group by nb.gid, nb.geog
),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct nb.gid
        ,coalesce(da.nodata, false) nodata
from (SELECT * FROM netbuffers WHERE radius=500) nb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(nb.geom, da.geom)
 2017-06-14 Methodology # B.Thierry 36

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 )
SELECT nb.postalcode
,nb.radius
,string_agg(distinct dar.dauid, ';' order by dar.dauid) dauids ,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2
,case nodata
when false then coalesce(round((1000000 * sum(pop_lur_dsty * ST_Area(ST_Transform(ST_Intersection(dar.geom, nb.geom),4326)::geography)) / lur_area_within_buf)::numeric, 1), 0)
        else -7
  end weighted_net_pop_density_km2
  ,case nodata
when false then coalesce(sum(no_residential), 0) else -7
 end approximated
FROM (SELECT * FROM netbuffers WHERE radius=500) nb
LEFT JOIN dar ON ST_Intersects(dar.geom, nb.geom)
LEFT JOIN dar_netpop USING (dauid)
LEFT JOIN nb_resid using (gid)
join discard_nodata using (gid)
GROUP BY nb.postalcode, nb.radius, nb.geog, lur_area_within_buf, nodata;
CREATE VIEW walkability_measures.net_pop_density_netbuf1000 AS
WITH dar AS
( -- Limit population to residential areas, unless no residential area exists
-- within DA, in which case the whole DA is considered instead.
-- We add a field [no_residential] to flag DA without residential areas
  SELECT dauid
        ,pop_total
        ,lur.gid::text lur_id
        ,CASE coalesce(lur.gid, -1)
WHEN -1 THEN 1
             ELSE 0
        END no_residential
        ,CASE COALESCE(lur.gid, -1)
             WHEN -1 THEN da.geom
             ELSE ST_Intersection(lur.geom, da.geom)
        END geom
  FROM census2006.da_pop da
  LEFT JOIN (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(da.geom, lur.geom) ),
dar_netpop AS
( -- Compute net population density.
SELECT dauid
,pop_total / sum(ST_Area(ST_Transform(geom, 4326)::geography))
pop_lur_dsty
,sum(ST_Area(ST_Transform(geom, 4326)::geography)) lur_area_within_da
  FROM dar
  GROUP by dauid, pop_total
 2017-06-14 Methodology # B.Thierry 37

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ),
nb_resid AS
( -- Compute residential area within buffer.
select nb.gid
,sum(ST_Area(ST_Intersection(nb.geog, lur.geog))) lur_area_within_buf
from (SELECT * FROM netbuffers WHERE radius=1000) nb
left join (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(nb.geom, lur.geom)
  group by nb.gid, nb.geog
),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct nb.gid
        ,coalesce(da.nodata, false) nodata
 from (SELECT * FROM netbuffers WHERE radius=1000) nb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(nb.geom, da.geom)
)
SELECT nb.postalcode
,nb.radius
,string_agg(distinct dar.dauid, ';' order by dar.dauid) dauids ,round(ST_Area(nb.geog)::numeric, 1) buffer_area_m2
,case nodata
when false then coalesce(round((1000000 * sum(pop_lur_dsty * ST_Area(ST_Transform(ST_Intersection(dar.geom, nb.geom),4326)::geography)) / lur_area_within_buf)::numeric, 1), 0)
        else -7
  end weighted_net_pop_density_km2
  ,case nodata
when false then coalesce(sum(no_residential), 0)
        else -7
  end approximated
FROM (SELECT * FROM netbuffers WHERE radius=1000) nb LEFT JOIN dar ON ST_Intersects(dar.geom, nb.geom) LEFT JOIN dar_netpop USING (dauid)
LEFT JOIN nb_resid using (gid)
join discard_nodata using (gid)
GROUP BY nb.postalcode, nb.radius, nb.geog, lur_area_within_buf, nodata;
4.6.1.3 net_pop_density_circbuf500 & net_pop_density_circbuf1000
  CREATE VIEW AS
WITH dar AS
( -- Limit population to residential areas, unless no residential area exists
-- within DA, in which case the whole DA is considered instead.
-- We add a field [no_residential] to flag DA without residential areas
  SELECT dauid
        ,pop_total
        ,lur.gid::text lur_id
        ,CASE coalesce(lur.gid, -1)
             WHEN -1 THEN 1
             ELSE 0
walkability_measures.net_pop_density_circbuf500
 2017-06-14 Methodology # B.Thierry 38

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
         END no_residential
        ,CASE COALESCE(lur.gid, -1)
             WHEN -1 THEN da.geom
             ELSE ST_Intersection(lur.geom, da.geom)
        END geom
  FROM census2006.da_pop da
LEFT JOIN (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(da.geom, lur.geom) ),
dar_netpop AS
( -- Compute net population density.
SELECT dauid
,pop_total / sum(ST_Area(ST_Transform(geom, 4326)::geography))
pop_lur_dsty
 ,sum(ST_Area(ST_Transform(geom, 4326)::geography)) lur_area_within_da FROM dar
  GROUP by dauid, pop_total
),
cb_resid AS
( -- Compute residential area within buffer.
select cb.gid
,sum(ST_Area(ST_Intersection(cb.geog, lur.geog))) lur_area_within_buf
from (SELECT * FROM circbuffers WHERE radius=500) cb
left join (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(cb.geom, lur.geom)
  group by cb.gid, cb.geog
),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct cb.gid
        ,coalesce(da.nodata, false) nodata
from (SELECT * FROM circbuffers WHERE radius=500) cb
left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(cb.geom, da.geom)
)
SELECT cb.postalcode
,cb.radius
,string_agg(distinct dar.dauid, ';' order by dar.dauid) dauids ,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2
 ,case nodata
when false then coalesce(round((1000000 * sum(pop_lur_dsty *
ST_Area(ST_Transform(ST_Intersection(dar.geom, cb.geom),4326)::geography)) / lur_area_within_buf)::numeric, 1), 0)
        else -7
  end weighted_net_pop_density_km2
  ,case nodata
when false then coalesce(sum(no_residential), 0)
        else -7
  end approximated
FROM (SELECT * FROM circbuffers WHERE radius=500) cb
 2017-06-14 Methodology # B.Thierry 39

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 LEFT JOIN dar ON ST_Intersects(dar.geom, cb.geom) LEFT JOIN dar_netpop USING (dauid)
LEFT JOIN cb_resid using (gid)
join discard_nodata using (gid)
GROUP BY cb.postalcode, cb.radius, cb.geog, lur_area_within_buf, nodata;
CREATE VIEW walkability_measures.net_pop_density_circbuf1000 AS
WITH dar AS
( -- Limit population to residential areas, unless no residential area exists
-- within DA, in which case the whole DA is considered instead.
-- We add a field [no_residential] to flag DA without residential areas
  SELECT dauid
        ,pop_total
        ,lur.gid::text lur_id
          ,CASE coalesce(lur.gid, -1)
             WHEN -1 THEN 1
             ELSE 0
        END no_residential
        ,CASE COALESCE(lur.gid, -1)
             WHEN -1 THEN da.geom
             ELSE ST_Intersection(lur.geom, da.geom)
        END geom
  FROM census2006.da_pop da
LEFT JOIN (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(da.geom, lur.geom) ),
dar_netpop AS
( -- Compute net population density.
SELECT dauid
,pop_total / sum(ST_Area(ST_Transform(geom, 4326)::geography))
pop_lur_dsty
,sum(ST_Area(ST_Transform(geom, 4326)::geography)) lur_area_within_da
FROM dar
  GROUP by dauid, pop_total
),
cb_resid AS
( -- Compute residential area within buffer.
select cb.gid
,sum(ST_Area(ST_Intersection(cb.geog, lur.geog))) lur_area_within_buf
 from (SELECT * FROM circbuffers WHERE radius=1000) cb
left join (SELECT * FROM streetfiles2006.canlur WHERE category='Residential') lur ON ST_Intersects(cb.geom, lur.geom)
  group by cb.gid, cb.geog
),
discard_nodata as
( -- Find buffers that intersect DA with no population value
  select distinct cb.gid
        ,coalesce(da.nodata, false) nodata
from (SELECT * FROM circbuffers WHERE radius=1000) cb
 2017-06-14 Methodology # B.Thierry 40

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 left join (SELECT geom, true nodata FROM census2006.da_pop WHERE pop_total is null) da ON ST_Intersects(cb.geom, da.geom)
)
SELECT cb.postalcode
,cb.radius
,string_agg(distinct dar.dauid, ';' order by dar.dauid) dauids ,round(ST_Area(cb.geog)::numeric, 1) buffer_area_m2
,case nodata
when false then coalesce(round((1000000 * sum(pop_lur_dsty * ST_Area(ST_Transform(ST_Intersection(dar.geom, cb.geom),4326)::geography)) / lur_area_within_buf)::numeric, 1), 0)
        else -7
  end weighted_net_pop_density_km2
  ,case nodata
 when false then coalesce(sum(no_residential), 0)
        else -7
  end approximated
FROM (SELECT * FROM circbuffers WHERE radius=1000) cb LEFT JOIN dar ON ST_Intersects(dar.geom, cb.geom) LEFT JOIN dar_netpop USING (dauid)
LEFT JOIN cb_resid using (gid)
join discard_nodata using (gid)
GROUP BY cb.postalcode, cb.radius, cb.geog, lur_area_within_buf, nodata;
4.6.2 Data dictionary
* The view for gross population density at postal code location shows the following variables: o postalcode:postalcodeofinterest
o dauid: dissemination area (DA) unique ID where the postal code falls
o resid_da_area_m2: residential area within DA, in sq. m.
o net_pop_density_km2: population density within DA where the postal code falls, expressed in inhabitants per sq.km
o approximated: flag = 1 when DA has a not null population value yet no residential area, in which case resid_da_area_m2 corresponds to the whole DA area
* The four views for gross population density in buffers show the following variables:
o postalcode: postal code on which the buffer is centered
o radius: radius (500m / 1km) of the buffer
o dauids: list of dissemination area unique IDs that intersect with the buffer
o buffer_area_m2: buffer area in sq. m.; circular buffer area are computed from the true shape, not the
mathematical formula
o weighted_net_pop_density_km2: weighted average of the population density within buffer, expressed in
inhabitants per sq.km
o approximated: flag > 0 when at least one of the DA used to compute the weighted net density has a not null
population value yet no residential area
 2017-06-14
Methodology # B.Thierry 41

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
4.7 Dwelling density
* The Census 2006 does not contain dwelling counts, we use instead the household count, which should lead to the same count given StatCan definition of a household9.
* This dwelling density does not account for the residential areas, considering instead the whole DA area and a homogenous population across the DA.
* To avoid CTE optimization fences, we create a view to compute the population density for each DA:
   Dwelling density
  Dwelling count per km2
  Total dwelling units in the dissemination area (DA) divided by the area of the DA in which the postal code is located
   2006 Census Boundary files 2006 Census dwelling counts Postal code coordinates (PCCF+)
    -- Create view to avoid CTE optimization fences
CREATE OR REPLACE VIEW census2006.da_dwell AS
  SELECT l.dauid
        ,d.total_households
,l.geom
,l.geog
FROM census2006.da_limits l
LEFT JOIN census2006.da_dwelling d ON (d.geography=l.dauid);
 4.7.1 Data extraction
4.7.1.1 dwelling_density_pc
TODO
4.7.1.2
TODO
4.7.1.3
TODO
4.7.2
TODO
4.8 Entropy – Land use mix
dwelling_density_netbuf500 & dwelling_density_netbuf1000
dwelling_density_circbuf500 & dwelling_density_circbuf1000
Data dictionary
    Entropy: Land Use Mix)
   n/a
  Degree of heterogenity in land uses contained in the buffer surrounding the postal code, calcuated using a commonly used entropy formula:
      CanMap Street files
Postal code coordinates (PCCF+)
 9 Household refers to a person or group of persons who occupy the same dwelling and do not have a usual place of residence elsewhere in Canada or abroad. The dwelling may be either a collective dwelling or a private dwelling. The household may consist of a family group such as a census family, of two or more families sharing a dwelling, of a group of unrelated persons or of a person living alone. Household members who are temporarily absent on reference day are considered part of their usual household. [http://www23.statcan.gc.ca/imdb/p3Var.pl?Function=Unit&Id=96113]
2017-06-14 Methodology # B.Thierry 42
 
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 NB. Entropy is dependant of the number of land use categories. By default, the DMTI land use dataset defines 7 classes,
 it is proposed to regroup them to define three new categories – Residential, Recreational, Employment. To be discussed:
 do we keep the 7 class entropy or do we propose only the 3 class one?
4.8.1 Data extraction
* Calculate the land use mix (entropy) using the classic formula (see for instance Frank, Lawrence D., et al. "Many pathways from land use to health: associations between neighborhood walkability and active transportation, body mass index, and air quality." Journal of the American Planning Association 72.1 (2006): 75-87).
*
.
4.8.1.1 landusemix_entropy_pc
Non applicable (no reference spatial unit provided)
4.8.1.2 landusemix_entropy_netbuf500 & landusemix_entropy_netbuf1000
 Entropy is computed if at least 99% of the buffer area overlays the land use cover, otherwise the buffer gets a
 NoData (-7) value
  CREATE VIEW                                                   as
WITH ratio_lu as
(
SELECT buf.gid, lur.category
,sum(ST_Area(ST_Intersection(buf.geog, lur.geog)) / ST_Area(buf.geog))
ratio
FROM (SELECT * FROM netbuffers WHERE radius=500) buf LEFT JOIN (SELECT * FROM streetfiles2006.canlur) lur ON
ST_Intersects(buf.geom, lur.geom)
  GROUP BY buf.gid, lur.category
)
SELECT buf.postalcode, buf.radius
  ,ST_Area(buf.geog) buffer_area_m2
  ,CASE
WHEN abs(sum(ratio * ST_Area(buf.geog)) / ST_Area(buf.geog)) > 0.99 THEN round(-sum(ratio * ln(ratio)/ln(7))::numeric, 3)
        ELSE -7
  END entropy
FROM (SELECT * FROM netbuffers WHERE radius=500) buf LEFT JOIN ratio_lu USING (gid)
GROUP BY buf.postalcode, buf.radius, buf.geog;
create view walkability_measures.landusemix_entropy_netbuf1000 as WITH ratio_lu as
 walkability_measures.landusemix_entropy_netbuf500
 (
  SELECT buf.gid, lur.category
,sum(ST_Area(ST_Intersection(buf.geog, lur.geog)) / ST_Area(buf.geog))
ratio
FROM (SELECT * FROM netbuffers WHERE radius=1000) buf LEFT JOIN (SELECT * FROM streetfiles2006.canlur) lur ON
ST_Intersects(buf.geom, lur.geom)
  GROUP BY buf.gid, lur.category
)
SELECT buf.postalcode, buf.radius
,ST_Area(buf.geog) buffer_area_m2
 2017-06-14 Methodology # B.Thierry 43

PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
 ,CASE
WHEN abs(sum(ratio * ST_Area(buf.geog)) / ST_Area(buf.geog)) > 0.99
THEN round(-sum(ratio * ln(ratio)/ln(7))::numeric, 3) ELSE -7
END entropy
FROM (SELECT * FROM netbuffers WHERE radius=1000) buf LEFT JOIN ratio_lu USING (gid)
GROUP BY buf.postalcode, buf.radius, buf.geog;
4.8.1.3 landusemix_entropy_circbuf500 & landusemix_entropy_circbuf1000
  CREATE VIEW                                                    as
WITH ratio_lu as
(
  SELECT buf.gid, lur.category
walkability_measures.landusemix_entropy_circbuf500
 ,sum(ST_Area(ST_Intersection(buf.geog, lur.geog)) / ST_Area(buf.geog))
ratio
FROM (SELECT * FROM circbuffers WHERE radius=500) buf LEFT JOIN (SELECT * FROM streetfiles2006.canlur) lur ON
ST_Intersects(buf.geom, lur.geom)
  GROUP BY buf.gid, lur.category
)
SELECT buf.postalcode, buf.radius
  ,ST_Area(buf.geog) buffer_area_m2
  ,CASE
WHEN abs(sum(ratio * ST_Area(buf.geog)) / ST_Area(buf.geog)) > 0.99 THEN round(-sum(ratio * ln(ratio)/ln(7))::numeric, 3)
        ELSE -7
  END entropy
FROM (SELECT * FROM circbuffers WHERE radius=500) buf LEFT JOIN ratio_lu USING (gid)
GROUP BY buf.postalcode, buf.radius, buf.geog;
create view walkability_measures.landusemix_entropy_circbuf1000 as WITH ratio_lu as
(
SELECT buf.gid, lur.category
,sum(ST_Area(ST_Intersection(buf.geog, lur.geog)) / ST_Area(buf.geog))
ratio
FROM (SELECT * FROM circbuffers WHERE radius=1000) buf
  LEFT JOIN (SELECT * FROM streetfiles2006.canlur) lur ON ST_Intersects(buf.geom, lur.geom)
  GROUP BY buf.gid, lur.category
)
SELECT buf.postalcode, buf.radius
  ,ST_Area(buf.geog) buffer_area_m2
  ,CASE
WHEN abs(sum(ratio * ST_Area(buf.geog)) / ST_Area(buf.geog)) > 0.99 THEN round(-sum(ratio * ln(ratio)/ln(7))::numeric, 3)
        ELSE -7
  END entropy
FROM (SELECT * FROM circbuffers WHERE radius=1000) buf
 2017-06-14 Methodology # B.Thierry 44

 LEFT JOIN ratio_lu USING (gid)
GROUP BY buf.postalcode, buf.radius, buf.geog;
4.8.2 Data dictionary
*
4.9
The four views for land use mix (entropy) in buffers show the following variables:
o postalcode: postal code on which the buffer is centered
o radius: radius (500m / 1km) of the buffer
o buffer_area_m2: buffer area in sq. m.; circular buffer area are computed from the true shape, not the
mathematical formula
o entropy: land use mix (entropy) of the buffer, NoData value (-7) if less than 99% of the buffer area is
covered by land use polygons
Interaction – Land use mix
PHAC Project: Surveillance of the Utilitarian Walking of Canadians Using GIS and Survey Data
    Length (in metres) of boundaries between different land use categories within each buffer
   CanMap Street files
Postal code coordinates (PCCF+)
 Interaction: Land Use Mix)
4.9.1 Data extraction
4.9.1.1 landusemix_interaction_pc
Non applicable (no reference spatial unit provided)
4.9.1.2 landusemix_interaction_netbuf500 & landusemix_interaction_netbuf1000
n/a
   2017-06-14 Methodology # B.Thierry 45
