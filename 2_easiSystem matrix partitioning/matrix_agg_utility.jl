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

using HiGHS, JuMP, DelimitedFiles


function matrix2list(origMatrix, dims = 1)
    "take a matrix and return a list of vectors; dims =1 for iterating through rows, dims = 2 for columns"
    if dims == 1
        return [[i for i in 1:length(origMatrix[1, :]) if origMatrix[j,:][i]==1] for j in 1:size(origMatrix)[dims]]
    else
        return [[i for i in 1:length(origMatrix[:, 1]) if origMatrix[:, j][i]==1] for j in 1:size(origMatrix)[dims]]
    end
end


#travel the satelite matrix over the rows to aggreagte them
function aggregateColumns(origMatrix, shrinkingIndices, weightingIndices, codes)
    newMatrix = []
    for line in 1:size(referenceMatrix)[1]
        # println("line: ", line)
        #for each subdivision of the satellite account (for example, there are 164x2x120 columns, so there will be 328 subdivisions along the columns)
        #aggregate the rows according to shrinkIndices and to weightIndices
        newLine = []
        for block in 1:size(origMatrix, 2)/length(codes)
            #get the block of the satellite matrix
            blockLine = origMatrix[line, Int64((1+(block-1)*length(codes))):Int64((block*length(codes)))]
            
            if block == 1
                newLine =  [sum(blockLine[a].*weightingIndices[a]) for a in shrinkingIndices]'
            else
                newLine = [newLine'; [sum(blockLine[a].*weightingIndices[a]) for a in shrinkingIndices]]'
            end
            
        end
        if line == 1
            newMatrix = newLine
        else
            newMatrix = [newMatrix; newLine]
        end
    end
    return newMatrix;
end