#   R function: Access vector country data from rworldmap package, and generate C# classes for use in Unity3D.
#
#   R version: 4.0.3
#   RStudio version: Version 1.4.1103 (OS X)
#
#   Author: Nico Reski and Aris Alissandrakis
#   Web: http://reski.nicoversity.com
#   Twitter: @nicoversity
#   GitHub: https://github.com/nicoversity


# install.packages("rworldmap")         # make sure you have the rworldmap package installed

library(rworldmap)                      # load rworldmap package

# query map data
worldMap <- getMap(resolution = "low")

# create data frame with all countries
# developer note 2021-02-02: For some reason, the 113 entry is titled NA, and thus not available. Therefore, it is excluded here in order to avoid issues when iterating through the country data.
countryDF <- data.frame(country = worldMap$NAME[! worldMap$NAME %in% c(worldMap$NAME[113])])

# have a look at the data frame in the console
countryDF


# === preparation: C# / Unity3D ===

# directory for storing the generated C# class files
unityClassesDirectory <- "rworldmap-unity-files/"

# create accompanying code snippet representing the initialization statements in Unity3D (generated file contents are to be copied into the WorldGenerator.cs script's Awake() function)
initFileConn<-file(sprintf("rworldmap-unity-files/_init.cs"))
initText = c()


# === C# class generation ===

# determine amount of countries in the collections
countriesCount <- length(countryDF$country)

# iterate over all countries
for (i in c(1:countriesCount))
{
    # helper values to keep track of how many map parts (Vectors with coordinates) there will be and what their names are
    partsCount = 0;
    partNames = list();
    
    
    # === rworldmap data export ===

    # store original country name according to rworldmap package (for data access)    
    country = as.character(countryDF$country[i])

    # normalize country name for use as C# class and variable names
    countryNormalized <- trimws(country)
    countryNormalized <- gsub(" ", "", countryNormalized, fixed = TRUE)
    countryNormalized <- gsub("&", "", countryNormalized, fixed = TRUE)
    countryNormalized <- gsub(".", "", countryNormalized, fixed = TRUE)
    countryNormalized <- gsub("'", "", countryNormalized, fixed = TRUE)
    countryNormalized <- gsub("(", "", countryNormalized, fixed = TRUE)
    countryNormalized <- gsub(")", "", countryNormalized, fixed = TRUE)
    
    # get index for current country
    index <- worldMap$NAME== country
    index[is.na(index)] <- FALSE
    
    # create polygon instance
    P <- worldMap[index,]@polygons
    
    # init text variable representing vector content for the current country
    vectorText = c()
    
    # iterate through all parts in the country polygon
    for (n in 1:min(length(P[[1]]@Polygons),100))
    {
        # keep track of part counts and name
        partsCount = n
        partNames = c(partNames, list(sprintf("%s_%i", countryNormalized, n)))
        
        # append header data
        vectorText = c(vectorText, sprintf("public static Vector2 [] %s_%i = new Vector2[] {", countryNormalized, n))
        
        # append vector data
        for (j in 1:length(P[[1]]@Polygons[[n]]@coords)/2)
        {
            vectorText = c(vectorText,
                         sprintf("    new Vector2(%ff,%ff),",
                                 P[[1]]@Polygons[[n]]@coords[j,1],
                                 P[[1]]@Polygons[[n]]@coords[j,2]
                         )
            )
        }
        vectorText = c(vectorText,"};")
    }
    
    
    # === unity classes creation ===
    
    # setup class name
    className = sprintf("MeshData%s", countryNormalized)
    
    # generate initialization entry for current exported country
    initText = c(initText, sprintf('initCountryWithMeshData("%s", new %s(), extrusionHeight, countryColor);', countryNormalized, className))
    
    # create C# file for current country
    fileConn <- file(paste(unityClassesDirectory, sprintf("%s.cs", className), sep=""))
    fileText = c()
    fileText = c(fileText, "using UnityEngine;")
    fileText = c(fileText, "using System.Collections;")
    fileText = c(fileText, "using System.Collections.Generic;")
    fileText = c(fileText, "")
    fileText = c(fileText, sprintf("public class %s : IRWMMeshData {", className))
    fileText = c(fileText, "")
    
    # append exported vector data
    fileText = (c(fileText, vectorText))
    fileText = c(fileText, "")
    
    # create parts count function
    fileText = c(fileText, sprintf("    public int partsCount { get; set; } = %i;", partsCount))
    fileText = c(fileText, "")
    
    # create get part of index function
    fileText = c(fileText, "    public Vector2[] getPartForIndex(int index) {")
    fileText = c(fileText, "")
    fileText = c(fileText, "        switch (index)")
    fileText = c(fileText, "        {")
    for(p in 1:length(partNames))
    {
        fileText = c(fileText, sprintf("        case %i:", p))
        fileText = c(fileText, sprintf("            return %s;", partNames[p]))
    }
    fileText = c(fileText, "        default:")
    fileText = c(fileText, "            return null;")
    fileText = c(fileText, "        }")
    fileText = c(fileText, "    }")
    fileText = c(fileText, "")
    
    # write contents to file
    fileText = c(fileText, "};")
    writeLines(fileText, fileConn)
    close(fileConn) 
}


# === unity initialization snippet  ===
# write initialization snipped to file
writeLines(initText, initFileConn)
close(initFileConn) 