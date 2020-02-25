# Create a script that compiles a raster stack at 1km spatial resolution 


# LIBRARIES AND SOURCED FUNCTIONS -----------------------------------------

# Libraries
library(raster)
# Source functions
source("code/RasterStack_Functions.R")


# INPUT DATASETS ----------------------------------------------------------
countrys <- c("ETH", "KEN", "NGA", "TZA", "ZMB")
elevation.paths <- list.files("data/SRTM_1km_ASC", full.names = TRUE, 
                              pattern = "*.asc$")
population.paths <- list.files("data/WorldPop", full.names = TRUE, 
                               pattern = "*.tif$")
bioclimatic.paths <- list.files("data/BIOclim", full.names = TRUE, 
                                pattern = "*.tif$")

projexions <- 
  list(WGS =  CRS("+proj=longlat +datum=WGS84 +no_defs
                   +ellps=WGS84 +towgs84=0,0,0"),
       LAEA = CRS("+proj=laea +lat_0=5 +lon_0=20 +x_0=0 +y_0=0 
                  +a=6370997 +b=6370997 +units=m +no_defs"))
# Output Projection
projexion <- "LAEA" # "WGS" # 
# 
# output.dir <- "output"

# DATA PREPARATION --------------------------------------------------------

# Create working sub-directiries
dir.create("scratch/shp", showWarnings=FALSE, recursive = TRUE)
dir.create("scratch/raster", showWarnings=FALSE, recursive = TRUE)
# dir.create(file.path(output.dir, "raster"), 
#            showWarnings=FALSE, recursive = TRUE)
# Load data
elevation.rasters_ <- lapply(elevation.paths, raster)  # 1Km by 1Km
bioclimatic.rasters_ <- lapply(bioclimatic.paths, raster) # 1Km by 1Km
population.rasters_ <- lapply(population.paths, raster) # 100m by 100m
# Download country shapefiles
countrys.shp <- getCountryShp(countrys, lvl=0, path = "scratch/shp")



# CLIP ELEVATION AND BIOCLIMATIC DATA TO COUNTRY BOUDERS ------------------

elevation.rasters <- maskCountry(countrys.shp[1:2], elevation.rasters_, 
                                 "elevation", projexion)
bioclimatic.rasters <- maskCountry(countrys.shp[1:2], bioclimatic.rasters_[1:3], 
                                   "bioclimatic", projexion)


# AGGREGATE POPULATION DATA TO 1KM ----------------------------------------

population.rasters <- aggregatePopRaster(population.rasters_[1:2], 
                                         "population", projexion)


