# Can-ALE

## Description

The Canadian Active Living Environments (Can-ALE) database is a geographic-based set of measures that represents the active living friendliness of Canadian communities. The primary envisioned use for Can-ALE is research and analysis of the relationship between the way communities are built and the physical activity levels of Canadians. 

The [Can-ALE User Guide and Technical Document](https://github.com/walkabillylab/Can-ALE/blob/main/03_CanALE_UserGuideAndTechnicalDocument.pdf) provides an overview of the key methodology and decision making. A French version of the user guide is also available [here](https://github.com/walkabillylab/Can-ALE/blob/main/FR_Guide_AVACan.pdf). 

## Data

There are two Can-ALE datasets, the 2006 Can-ALE Dataset includes two measures derived from 2006 data for geographic units corresponding to 2006 geographies, whereas the 2016 Can-ALE dataset includes four measures derived from 2016 or 2017 data for geographic units corresponding to 2016 geographies. Census years were selected for the dataset to facilitate the use of census data by users. Users are discouraged from performing longitudinal analyses using data from both the 2006 and 2016 datasets, as the derivation methodologies and census geographies changed between the reference years.

__Our team is currently working on a 2021 Census Year Can-ALE measure.__

| Dataset | Data Download |
| ------- | ------------- |
| 2006 Can-ALE Dataset | [CanALE_2006.csv](https://github.com/walkabillylab/Can-ALE/blob/main/Data/CanALE_2006.csv) |
| 2016 Can-ALE Dataset | [CanALE_2016.csv](https://github.com/walkabillylab/Can-ALE/blob/main/Data/CanALE_2016.csv) |

Can-ALE data linked to postal codes are available from the [Canadian Urban Environmental Health Research Consortium](https://www.canuedata.ca/metadata.php). CANUE data users will be required to sign a data sharing agreement in order to use the linked data.  

###  Geographic unit of analysis

Can-ALE measures are based on one-kilometre, circular (Euclidean) buffers drawn from the centre points (centroids) of Dissemination Areas (DAs). DAs are small geographic units defined by Statistics Canada, with a population of between 400 to 700 persons. All of Canada is divided into DAs. This is the smallest geographic unit for which complete census data is released across all of Canada [14]. DA boundaries are created by and can be downloaded online from Statistics Canada.

### File format and naming convention
Both Can-ALE datasets are provided in the Comma Separated Values (.csv) format. This file format may be opened easily in spreadsheet programs (e.g., Microsoft Excel, Google Sheets) and statistical software (e.g., STATA, SPSS, R).
The datasets are named using the following naming convention: six-character file name (i.e., “CanALE”), underscore (“_”), reference year for the geographic units (e.g., “2016”). The two files, therefore, are:

### Dataset completeness
For the 2006 dataset, two measures were produced for all dissemination areas (DAs) in Canada (intersection density and dwelling density). For the 2016 dataset, three measures were produced for all DAs in Canada (intersection density, dwelling density, and points of interest), and one measure was produced for all DAs within Census Metropolitan Areas (CMAs) in Canada (transit stops).

Intersection density was derived successfully for all DAs for both 2006 and 2016, and points of interest was derived successfully for all DAs for 2016.

Dwelling density values are not present for 410 DAs in 2006 and 500 DAs in 2016 (see Table A2, pages 17-18). All DAs with no values (null) are assigned a period (“.”). In all instances of null dissemination area values, the DA buffer was located entirely within a DA where Statistics Canada does not disseminate data on dwelling counts (e.g., First Nations reserves).

The transit measure (unique to the 2016 dataset) covers DAs in Canada’s largest cities, known as Census Metropolitan Areas (CMAs). The transit measure was derived for 35,338 DAs (97.1% of the DAs within CMAs). Spatial data on transit stop locations was unavailable for a few smaller CMAs: Belleville, ON; Peterborough, ON; Saguenay, QC; and Trois-Rivières, QC.

## Cross-Walk File

The “CanALE DA Crosswalk File” this file is envisioned to provide a one-to-one geographic correspondence between dissemination area geographies from different census years. This file contains 220,331 unique records, which represent the centroids (centre points) of dissemination areas for four census years (2001, 2006, 2011, 2016). The unique identifier (“UID”) is a thirteen-character field, which consists of the census year, an underscore (“_”), and the eight-digit unique identifier for the dissemination area (DA) for the unique centroid. For instance, UID “2001_10010001” represents the centroid of DA ‘10010001’, which was valid in the 2001 census year.

[Full detail and data for the cross-walk file are provided here](https://github.com/walkabillylab/Can-ALE/tree/main/CanALE_DA_Crosswalk_File)

## Citation

We ask that you cite the following if you are using Can-ALE in published work.

1. Ross, N., Wasfi, R., Herrmann, T., and Gleckner, W., 2018. Canadian Active Living Environments Database (Can-ALE) User Manual & Technical Document. Geo-Social Determinants of Health Research Group, Department of Geography, McGill University.

