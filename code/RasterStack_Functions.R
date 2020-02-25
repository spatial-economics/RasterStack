maskCountry <- function(countrys, raster.files, category, projexion) {
  output.list <- list()
  for (cntry in countrys) {
    i <- 0
    cntry.rasters <- list()
    for (raster.file in raster.files){
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
      cntry.extent <- crop(raster.file, cntry, 
                           filename="scratch/tmp.tif", overwrite=TRUE)
      cntry.rasters[[i]] <- mask(cntry.extent, cntry,
                                 filename = output.file, overwrite=TRUE)
    }
    output.list[[cntry$GID_0[1]]] <- cntry.rasters
    
  }
  output.list
}

aggregatePopRaster <- function(raster.files, category, projexion) {
  output.list <- list()
  i <- 0
  for (raster.file in raster.files){
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
    output.list[[i]] <- aggregate(raster.file, fact=10, fun=sum, expand=TRUE, 
                                  na.rm=TRUE, filename=output.file, overwrite=TRUE)
  }
  output.list
}



