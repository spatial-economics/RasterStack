# Extract point values from rasters

library(raster)


# INPUTS ------------------------------------------------------------------

# CSV with Latitude, Longitude and Coutry columns
locations.path <- "data/csv/testCorrds.csv"
# Points projection
coordsystms <- "WGS" # LAEA #
coordsystms.list <- 
  list(WGS =  CRS("+proj=longlat +datum=WGS84 +no_defs
                   +ellps=WGS84 +towgs84=0,0,0"),
       LAEA = CRS("+proj=laea +lat_0=5 +lon_0=20 +x_0=0 +y_0=0 
                  +a=6370997 +b=6370997 +units=m +no_defs"))
countries <- c("ETH", "TZA") # c("ETH", "KEN", "NGA", "TZA", "ZMB")
variables <- c("elevation",  "bioclimatic", "population")

# Rasters folder
raster.parent.dir <- "scratch/raster"

# Extraction parameters
method <- 'simple'  # 'simple' or 'bilinear'
buffer_ <- 5000     # Around points: Should be in map-units (typically  meters)
fun_ <- mean        # Function to summarize the values


# DATA PREPARATION --------------------------------------------------------

locations.csv <- read.csv(locations.path)
locations.shp <- SpatialPointsDataFrame( coords = data.frame(
                                                  locations.csv[,"Longitude"],
                                                  locations.csv[,"Latitude"]
                                                  ),
                                         data = locations.csv, 
                                         proj4string = coordsystms.list[["WGS"]]
                                         )

# # COUNTRY PROBLEM
locations.shp1 <- locations.shp

for (cntry in countries) {
  for (variable in variables) {
    for (coordsys in coordsystms) {
      raster.dir <- file.path(raster.parent.dir, cntry, variable, coordsys)
      if(!dir.exists(raster.dir)) {next()}
      raster.paths <- list.files(raster.dir, pattern = "*.tif$", full.names = TRUE)
      if(length(raster.paths) == 0) {next()}
      raster.stack <- stack(raster.paths)
      print(raster.paths)
      for (count in 1:dim(raster.stack)[3]){

        locations.shp1 <- extract(raster.stack@layers[[count]],
                                 locations.shp1, 
                                 method=method, 
                                 layer=1,
                                 nl=dim(raster.stack)[3],
                                 sp=TRUE, buffer=buffer_, small=TRUE, fun=fun_,  
                                 na.rm=TRUE )
        }}}}




