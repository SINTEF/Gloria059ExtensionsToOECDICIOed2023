# #####################################################################################
# Copyright (c) 2025, SINTEF (http://www.sintef.no) 
# All rights reserved.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, you can obtain one at http:#mozilla.org/MPL/2.0/.
# SPDX-License-Identifier: MPL-2.0
# #####################################################################################
# Gerardo A Perez-Valdes <GerardoA.Perez-Valdes@sintef.no>
# 2024-05-16

#Aggregation of matrices from Gloria to OECD format
using DelimitedFiles, XLSX, Random, Dates

include("matrix_agg_utility.jl");

dirCurrent = "";  #This is where this file is located
dirOriginals = "1_GLORIA_SatelliteAccounts_059_2020/";   # this is where the gloria IO used for reference is located
dirReference = "EasiSystem";   #this is where the satellite data and correspondence file is located 

#load the satellite data in 
referenceMatrix =   readdlm("1_GLORIA_SatelliteAccounts_059_2020/20231117_120secMother_AllCountries_002_TQ-Results_2020_059_Markup001(full).csv", ',', header=false);

#load the convergence/correspondence matrix 
excelFile = XLSX.readxlsx(dirOriginals*"/GLORIA_ReadMe.xlsx");
correspondanceMatrix = excelFile["GLORIA 97-to-120 concordance"]["C2:DR98"];
# gloria97Names = excelFile["GLORIA 97-to-120 concordance"]["B2:B98"]
# gloria97Codes = string.(excelFile["GLORIA 97-to-120 concordance"]["A2:A98"])
gloria120Codes = string.(excelFile["GLORIA 97-to-120 concordance"]["C1:DR1"]);



#get the correspondence matrix from the file
correspFile = XLSX.readxlsx(dirReference*"/MappingIndCode_GLORIAvsOECD.xlsx");
#Get the original column of codes from col a
gloriaCodes  = correspFile[1]["A2:A122"];
#Get the original column of names from col b
gloriaNames = correspFile[1]["B2:B122"];
#Get the new column of codes from col c
oecdCodes = correspFile[1]["C2:C122"];
oecdNames = correspFile[1]["D2:D122"];


gloriaOECDMatrix = zeros(length(unique(gloriaCodes)), length(unique(oecdCodes)))
for line in eachindex(gloriaCodes)
        gloriaOECDMatrix[ indx(unique(gloriaCodes),gloriaCodes[line]), indx(unique(oecdCodes), oecdCodes[line])] = 1;
end

#get the srhinking indez list using 1 for 'rows'
shrinkIndices = matrix2list(gloriaOECDMatrix',  1);

#get the weights for each element of the list
weightIndices = (sum(gloriaOECDMatrix', dims=1)').^-1;

sum(weightIndices)
length(gloria120Codes)

finalMatrix = aggregateColumns(referenceMatrix, shrinkIndices, weightIndices, gloriaCodes[1:end-1]);

sum(finalMatrix)
sum(referenceMatrix)
size(finalMatrix)
size(referenceMatrix)
for checkV in 1:164*2
    println(sum(finalMatrix[:, (checkV-1)*(45)+1: checkV*45]))
    println(sum(referenceMatrix[:, (checkV-1)*(120)+1: checkV*120]))
end
#write the matrix to a file
writedlm(dirCurrent * "2023_satelliteGloriaToOECD_1.csv", finalMatrix, ',')