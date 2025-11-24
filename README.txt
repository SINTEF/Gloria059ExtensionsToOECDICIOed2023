# #####################################################################################
# Copyright (c) 2025, SINTEF (http://www.sintef.no) 
# All rights reserved.
# This Source Code Form is subject to the terms of the 
# GNU General Public License v3.0
# #####################################################################################


# Converting the Gloria Satellite accounts to ICIO is done in 3 steps

1. Download the data (1_GLORIA_SatelliteAccounts_059_2020)
2. Convert the industry classification (2_easiSystem matrix partitioning)
3. Convert the country classification (3_GVCtools_extensions)


---------------------------------------------------------------------------
# 1. Download the data (1_GLORIA_SatelliteAccounts_059_2020)
---------------------------------------------------------------------------

Go to the link in the links.txt and download the relevant release and year 
data from Gloria.

Copy the file with the letters "TQ" into the folder (T is transaction matrix, 
in contrast to Y which is direct impacts by final demand")
"2_easiSystem matrix partitioning\EasiSystem\"

in our case it was
20231117_120secMother_AllCountries_002_TQ-Results_2020_059_Markup001(full).csv



---------------------------------------------------------------------------
# 2. Convert the industry classification (2_easiSystem matrix partitioning)
---------------------------------------------------------------------------

The script is written in Julia. 

All the relevant files are included, but the paths in the first lines of 
the document will need to be adjusted.

The input files, that is the raw data and the conversion key, are in the
folder EasiSystem.

The output file is 2023_satelliteGloriaToOECD_1.csv.


---------------------------------------------------------------------------
#3. Convert the country classification (3_GVCtools_extensions)
---------------------------------------------------------------------------

The script is written in R.

The output file from step 2, is one of the input files here.

Gloria has more than 5000 Extensions, the files selectedExtensions.xlsx 
selects those that are of interest. Here, you can choose what you want.
 
You need to load coucodes (country codes), indcodes (industry codes), 
output X, and F, and S from ICIO2023 year2020,
where F contains extensions (e.g. GHG, EMPN, LABR, VA) from the OECD data
and related intensities S.

