# Create a script that compiles a raster stack at 1km spatial resolution 


# LIBRARIES AND SOURCED FUNCTIONS -----------------------------------------

# Libraries
library(raster)
# Source functions
source("code/RasterStack_Functions.R")


# INPUT DATASETS ----------------------------------------------------------

elevation.paths <- list.files("data/SRTM_1km_ASC", full.names = TRUE, 
                              pattern = "*.asc$")
population.paths <- list.files("data/WorldPop", full.names = TRUE, 
                               pattern = "*.tif$")
bioclimatic.paths <- list.files("data/BIOclim", full.names = TRUE, 
                                pattern = "*.tif$")

output.dir <- "output"
projexion <- "WGS" # LAEA


# DATA PREPARATION --------------------------------------------------------

# Create working sub-directiries
dir.create("scratch/shp", showWarnings=FALSE, recursive = TRUE)
dir.create("scratch/raster", showWarnings=FALSE, recursive = TRUE)
dir.create(file.path(output.dir, "raster"), 
           showWarnings=FALSE, recursive = TRUE)
# Load data
elevation.rasters <- lapply(elevation.paths, raster)  # 1Km by 1Km
bioclimatic.rasters <- lapply(bioclimatic.paths, raster) # 1Km by 1Km
population.rasters_ <- lapply(population.paths, raster) # 100m by 100m

# Download country shapefiles
eth0 <- getData("GADM", country = "ETH", level = 0, path = "scratch/shp")
ken0 <- getData("GADM", country = "KEN", level = 0, path = "scratch/shp")
nga0 <- getData("GADM", country = "NGA", level = 0, path = "scratch/shp")
tza0 <- getData("GADM", country = "TZA", level = 0, path = "scratch/shp")
zmb0 <- getData("GADM", country = "ZMB", level = 0, path = "scratch/shp")
countrys <- list(ETH = eth0, KEN = ken0, NGA = nga0, TZA = tza0, ZMB = zmb0)

# Propjections
projexions <- 
  list(WGS =   CRS("+proj=longlat +datum=WGS84 +no_defs
                   +ellps=WGS84 +towgs84=0,0,0"),
       LAEA = CRS("+proj=laea +lat_0=5 +lon_0=20 +x_0=0 +y_0=0 
                  +a=6370997 +b=6370997 +units=m +no_defs"))


# CLIP DATA TO COUNTRY BOUDERS --------------------------------------------

elevation.rasters <- maskCountry(countrys, elevation.rasters, 
                                 "elevation", projexion)
bioclimatic.rasters <- maskCountry(countrys, bioclimatic.rasters, 
                                   "bioclimatic", projexion)



# AGGREGATE POPULATION DATA -----------------------------------------------



