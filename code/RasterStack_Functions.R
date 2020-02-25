# Propjections
projexions <- 
  list(WGS =  CRS("+proj=longlat +datum=WGS84 +no_defs
                   +ellps=WGS84 +towgs84=0,0,0"),
       LAEA = CRS("+proj=laea +lat_0=5 +lon_0=20 +x_0=0 +y_0=0 
                  +a=6370997 +b=6370997 +units=m +no_defs"))


maskCountry <- function(countrys, raster.files, category, projexion) {
  # Mask raster file to countries boundaries
  output.list <- list()
  newproj <- toString(projexions[[projexion]])
  for (cntry in countrys) {
    i <- 0
    cntry.rasters <- list()
    for (raster.file in raster.files){
      oldproj <- toString(crs(raster.file))
      i <- i + 1
      output.file <-
        file.path(
          "scratch/raster/",
          cntry$GID_0[1],
          category,
          projexion,
          paste0(cntry$GID_0[1],
                 "_",
                 names(raster.file),
                 ".tif")
        )
      
      dir.create(dirname(output.file), showWarnings = FALSE, recursive = TRUE)
      # Transform shapefile if it's projection is diffrent from raster's
      if (!oldproj == toString(cntry@proj4string)) cntry <- spTransform(cntry,
                                                              crs(raster.file))
      # Crop extent before masking to speed mask process
      cntry.extent <- crop(raster.file, cntry, 
                           filename="scratch/tmp.tif", overwrite=TRUE)
      cntry.rasters[[i]] <- mask(cntry.extent, cntry,
                                 filename = output.file, overwrite=TRUE)
      # Transform raster if projection is diffrent from required
      if ( !oldproj == newproj){
        cntry.rasters[[i]] <- projectRaster(cntry.rasters[[i]], 
                                            crs=CRS(newproj),
                                            filename = output.file, 
                                            overwrite=TRUE)
        }
    }
    output.list[[cntry$GID_0[1]]] <- cntry.rasters
    
  }
  output.list
}

aggregatePopRaster <- function(raster.files, category, projexion) {
  # Aggregate a raster files from a list 
  output.list <- list()
  newproj <- toString(projexions[[projexion]])
  i <- 0
  for (raster.file in raster.files){
    oldproj <- toString(crs(raster.file))
    i <- i + 1
    output.file <-
      file.path(
        "scratch/raster/",
        toupper(substring(names(raster.file), 1, 3)),
        category,
        projexion,
        paste0(toupper(substring(names(raster.file), 1, 3)),
               "_",
               names(raster.file),
               ".tif")
      )
    dir.create(dirname(output.file), showWarnings = FALSE, recursive = TRUE)
    output.list[[i]] <- aggregate(raster.file, fact=10, fun=sum, 
                                  expand=TRUE, na.rm=TRUE, filename=output.file,
                                  overwrite=TRUE)
    
    # Transform aggregated raster if projection is diffrent from required
    if (!oldproj == newproj){
      output.list[[i]] <- projectRaster(output.list[[i]], crs=CRS(newproj),
                                        filename = output.file, overwrite=TRUE)
    }
  }
  output.list
}

getCountryShp <- function(cntrys.vector, lvl, path) {
  # Get country shapefiles from GADM
  output.list <- list()
  for (cntry in cntrys.vector) {
    output.list[[cntry]] <- getData("GADM", country=cntry, level=lvl, path=path)
  }
  output.list
}

