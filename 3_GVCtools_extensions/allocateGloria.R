# #####################################################################################
# Copyright (c) 2025, SINTEF (http://www.sintef.no) 
# All rights reserved.
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, you can obtain one at http:#mozilla.org/MPL/2.0/.
# SPDX-License-Identifier: MPL-2.0
# #####################################################################################


############################################################################
# Allocate GLORIA extensions to GVCTools
############################################################################
# 2024-05-28
# Kirsten S. Wiebe

# very loosely based on script GVCtools_allocateGloriaExtensions
# 2023-10-17, last updated 2023-10-17
# moana.simas@sintef.no


metadatapath = "inputdata/GLORIA/"
indatapath = "../2_easiSystem matrix partitioning"

#****************************************************************************
# reading meta data
#****************************************************************************
Gloriareadme = paste0(metadatapath,"GLORIA_ReadMe_059_ICIOcountries.xlsx")

ind_codes <- indcodes #OECD
satellite_info <- read_excel(Gloriareadme,sheet = "Satellites")
regions_info <- read_excel(Gloriareadme,sheet = "Regions")
nreg = dim(regions_info)[1]
ICIOcou_info <- coucodes #OECD


#****************************************************************************
# reading extensions
#****************************************************************************
# read in all extensions
rawdatalarge <- as.matrix(read.csv(paste0(indatapath,"2023_satelliteGloriaToOECD_1.csv"), header = FALSE))

# selecting only the ones that are intersting for us
# if we want more, it is just to include the info in the selectedExtensions.xlsx
# the read_excel automatially reads all the data in the sheet, without having to 
# specify rows and columns
selsats <- read_excel(paste0(metadatapath,"selectedExtensions.xlsx"),sheet = "Gloria059")
rawdata <- rawdatalarge[selsats$Lfd_Nr,]
rownames(rawdata) = selsats$Sat_indicator
rm(rawdatalarge)

nsat <- dim(rawdata)[1] 
ncol <- dim(rawdata)[2]

# number of regions in Gloria
ncol/nind/2 == nreg # /2 because it is always for use and supply

#****************************************************************************
# get rid of the parts corresponding to supply matrices
#****************************************************************************
rawdatainclsup = rawdata
for(r in nreg:1){
  r1 = (2*(r-1)*nind)+nind+1
  r2 = 2*r*nind
  rawdata = rawdata[,-(r1:r2)]
}
#dimnames(rawdata)[[2]] = paste0(rep(r))
rowSums(rawdata) == rowSums(rawdatainclsup)
rm(rawdatainclsup)

#****************************************************************************
# Make a satellite account matrix and fill for ICIO countries
#****************************************************************************
Fgloria = array(0,dim=c(nsat,nindcou))
dimnames(Fgloria)[[1]] = selsats$Sat_indicator
dimnames(Fgloria)[[2]] = couindcodes

for(c in coucodes[-ncou]){
  if(c != "TWN"){
    r = which(regions_info$ICIO_Regions == c)
    r1 = (r-1)*nind+1
    r2 = r*nind
    Fgloria[,paste0(c,"_",indcodes)] = rawdata[,r1:r2]
  }
}

for(r in 1:nreg){
  if(regions_info$ICIO_Regions[r] == "ROW"){
    r1 = (r-1)*nind+1
    r2 = r*nind
    Fgloria[,paste0("ROW_",indcodes)] = Fgloria[,paste0("ROW_",indcodes)] + rawdata[,r1:r2]
  }
  
}

# check if we got everything
round(rowSums(Fgloria),8) == round(rowSums(rawdata),8)


#****************************************************************************
# Calculate intensities and save
#****************************************************************************

Sgloria = t(t(Fgloria)/X) # X = OECD output
dimnames(Sgloria)[[1]]

save(Fgloria, file="Fgloria.Rdata")
save(Sgloria, file="Sgloria.Rdata")


#****************************************************************************
# checking GHG
#****************************************************************************
# F and S include OECD extensions GHG, EMPL, LABR, VA

GHG = rbind(t(F[,"PROD_GHG"]),Fgloria["'GHG_total_EDGAR_consistent'",]/1e3,Fgloria["'GHG_total_OECD_consistent'",]/1e3)
GHGint = rbind(t(S[,"PROD_GHG"]),Sgloria["'GHG_total_EDGAR_consistent'",]/1e3,Sgloria["'GHG_total_OECD_consistent'",]/1e3)

rowSums(GHG)

plot(GHG[1,]/GHG[3,],ylim=c(0,10))
lines(GHG[1,]/GHG[2,],type = "p",col="red")

# sum over countries
GHGcountry = array(0,dim=c(3,ncou))
dimnames(GHGcountry)[[2]] = coucodes
for(c in 1:ncou){
  c1=(c-1)*nind+1
  c2=c*nind
  GHGcountry[,c] = rowSums(GHG[,c1:c2])
}

plot(GHGcountry[1,],ylim=c(0,max(GHGcountry)+1000))
lines(GHGcountry[2,],type = "p",col="red")
lines(GHGcountry[3,],type = "p",col="blue")

plot(GHGcountry[1,]/GHGcountry[3,])
lines(GHGcountry[1,]/GHGcountry[2,],type = "p",col="red")
lines(GHGcountry[3,]/GHGcountry[2,],type = "p",col="blue")

