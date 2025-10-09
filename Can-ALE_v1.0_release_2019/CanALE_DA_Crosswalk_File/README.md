# CanALE DA Crosswalk File

## Format
This file is provided as a spreadsheet in Excel format (.xlsx) called “CanALE_DA_Crosswalk_File”

| Dataset | Data Download |
| ------- | ------------- |
| CanALE DA Crosswalk File | [CanALE_DA_Crosswalk_File.xlsx](https://github.com/walkabillylab/Can-ALE/blob/main/CanALE_DA_Crosswalk_File/CanALE_DA_Crosswalk_File.xlsx) |

## About this file

This file is envisioned to provide a one-to-one geographic correspondence between dissemination area geographies from different census years. This file contains 220,331 unique records, which represent the centroids (centre points) of dissemination areas for four census years (2001, 2006, 2011, 2016). The unique identifier (“UID”) is a thirteen-character field, which consists of the census year, an underscore (“_”), and the eight-digit unique identifier for the dissemination area (DA) for the unique centroid. For instance, UID “2001_10010001” represents the centroid of DA ‘10010001’, which was valid in the 2001 census year.

Following the “UID” field, the same information is provided in separate fields (“DAUID” and “YEAR”).

Following these records, there are four fields which indicate the DA polygon in which the unique DA centroid would fall inside for each of the four census years. Continuing to follow the UID record “2001_10010001”, the value in the “dauid16” column indicates that the 2001 DA ‘10010001’ would fall inside the boundaries of the 2016 DA ‘10010497’).

## Methodology

To assign the unique centroids to a dissemination area for each census year, the following method was used

*	The cartographic boundary files of dissemination areas (DAs) were downloaded from Statistics Canada’s website 
*	For each census year, the centroid was derived using the “Feature to Point” tool in ArcMap 10.5.1 (ESRI, Redlands, CA)
*	Each of the centroid files were merged into a single shapefile.
*	An intersection of the merged centroid file and the dissemination area polygon boundaries for each census year was performed. This assigns each centroid (representing a single DA for a unique census year) to the dissemination area polygon it falls inside. 

## How to use

*	Determine census year of data that you wish to link to Can-ALE
*	Filter the records based on the desired census year (e.g., “2011”)
*	Refer to “dauid06” or “dauid16” fields to link to census geographies for 2006 or 2016, respectively

## Data Dictionary

| Field name | Full name |	Description |
| ---------- | --------- | ------------ |
| UID	| Unique dissemination area centroid	| The unique identifier (primary key): four digit census year, underscore (“_”), and eight-digit dissemination area ID |
| DAUID	| Dissemination area unique identifier	| The unique, eight-digit dissemination area ID |  
| YEAR	| Census year	| The census year (2001, 2006, 2011, or 2016)  |
| dauid16	| 2016 dissemination area	| The location of the unique DA centroid according to 2016 census census geographies |
| dauid11	| 2011 dissemination area	| The location of the unique DA centroid according to 2011 census census geographies |
| dauid06	| 2006 dissemination area	| The location of the unique DA centroid according to 2006 census census geographies |
| dauid01	| 2001 dissemination area	| The location of the unique DA centroid according to 2001 census census geographies |

