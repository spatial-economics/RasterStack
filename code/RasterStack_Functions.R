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
          "cntry$GID_0[1]",
          category,
          projexion,
          paste0(cntry$GID_0[1],
                 "_",
                 names(raster.file),
                 ".tif")
        )
      
      dir.create(dirname(output.file), showWarnings = FALSE, recursive = TRUE)
      cntry.extent <- crop(raster.file, cntry, 
                           filename="scratch/tmp.tif")
      cntry.rasters[[i]] <- mask(cntry.extent, cntry,
                                 filename = output.file)
    }
    output.list[cntry$GID_0[1]] <- cntry.rasters
    
  }
  output.list
}





