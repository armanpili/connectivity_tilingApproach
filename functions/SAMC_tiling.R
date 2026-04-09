samc_tiling <- function(dataResistance,
                        dataAbsorption,
                        dataInitiation,
                        extentFocalArea,
                        tileDimensions, # 2 values for rows and cols
                        bufferDistance,
                        purgeExistingTiles = TRUE,
                        domainName,
                        saveFile = TRUE){
  
  require(pryr)
  require(tidyverse)
  require(terra)

  nTile <- tileDimensions[1] * tileDimensions[2]
    
  message("Case study: ", domainName)  
  message("Creating ", tileDimensions[1] * tileDimensions[2] ," tiles.")  
  message(".......................................................0%")

  tileZone <- rast(
    nrows= tileDimensions[1], # number of tile rows
    ncols = tileDimensions[2], # number of tile cols
    extent = extentFocalArea # Extent of main landscape
  )
  
  message("Creating input folders")  
  
  
  folderPaths <- c("../input",
                   paste0("../input/", domainName),
                   paste0("../input/", domainName, "/tiles_", nTile),
                   paste0("../input/", domainName, "/tiles_", nTile, "/resistance"),
                   paste0("../input/", domainName, "/tiles_", nTile, "/absorption"),
                   paste0("../input/", domainName, "/tiles_", nTile, "/initiation"),
                   paste0("../input/", domainName, "/tiles_", nTile, "/initiation/temp")
  )
  
  for(i in folderPaths) {
    # Check if folder exists; if not, create it
    if (!dir.exists(i)) {
      dir.create(i)
      message("...Folder created: ", i)
    } else {
      message("...Folder already exists: ", i)
      
    }
  }
  
  message("Purging all pesky tif files!")
  if (purgeExistingTiles == TRUE) {
    file.remove(list.files(folderPaths, 
                           pattern = ".tif", 
                           full.names = TRUE))
  }
  
  message("=====..................................................10%")
  
  
  message("Creating Resistance tiles")  
  
  res_tiles <- makeTiles(
    x = dataResistance, # spatial raster/stack 
    y = tileZone, # spatRaster/spatVector defining the zones.
    extend = FALSE, # default; whether to expand extent of y to cover all of x.
    na.rm = FALSE, # default; whether to ignore tiles with only missing values.
    buffer = bufferDistance, # allows the tiles to have buffers each.
    filename = paste0("../input/", 
                      domainName, 
                      "/tiles_", nTile, 
                      "/resistance/res_.tif"),
    overwrite = TRUE
  )
  
  message("...Success!!!")  
  
  message("=======================................................40%")
  
  message("Creating Absorption tiles")  
  
  
  abs_tiles <- makeTiles(
    x = dataAbsorption, # spatial raster/stack 
    y = tileZone, # spatRaster/spatVector defining the zones.
    extend = FALSE, # default; whether to expand extent of y to cover all of x.
    na.rm = FALSE, # default; whether to ignore tiles with only missing values.
    buffer = bufferDistance, # allows the tiles to have buffers each.
    filename = paste0("../input/", 
                      domainName, 
                      "/tiles_", nTile, 
                      "/absorption/abs_.tif"),
    overwrite = TRUE
  )
  
  message("...Success!!!")  
  
  message("========================================...............70%")
  
  message("Creating Initiation tiles")  
  
  
  init_temp <- makeTiles(
    x = dataInitiation, # spatial raster/stack 
    y = tileZone, # spatRaster/spatVector defining the zones.
    extend = FALSE, # default; whether to expand extent of y to cover all of x.
    na.rm = FALSE, # default; whether to ignore tiles with only missing values.
    filename = paste0("../input/", 
                      domainName, 
                      "/tiles_", nTile, 
                      "/initiation/temp/init_temp.tif"),
    overwrite = TRUE
  )
  
  init_tiles <- rep(NA, 
                    length(init_temp))
  
  for (i in 1:length(init_temp)) {
    
    temp <- rast(init_temp[i])
    
    temp <- extend(x = temp, 
                   y = bufferDistance, 
                   fill = 0)
    
    writeRaster(temp, 
                filename = paste0("../input/", 
                                  domainName, 
                                  "/tiles_", nTile, 
                                  "/initiation/init_", i, ".tif"),
                overwrite = TRUE)
    
    init_tiles[i] <- paste0("../input/", 
                            domainName, 
                            "/tiles_", nTile, 
                            "/initiation/init_", i, ".tif")
  }
  
  file.remove(list.files(paste0("../input/",
                                domainName, 
                                "/tiles_", nTile,
                                "/initiation/temp"), 
                         pattern = ".tif", 
                         full.names = TRUE))
  
  message(".........Success!!!")  
  
  message("====================================================...90%")

  
  domainExtent <- as.vector(ext(dataResistance))
  
  objectOutput <- list(name = domainName,
                       resistance = res_tiles,
                       absorption = abs_tiles,
                       initiation = init_tiles,
                       domainExtent = domainExtent,
                       temporary = init_temp
                        )

  if(saveFile == TRUE) {
    saveRDS(object = objectOutput, 
            file = paste0("../input/", 
                          domainName, "/", 
                          "/tiles_", nTile, "/",
                          domainName, "_tiles_", nTile, ".rds")
    )
  }
  
  return(objectOutput)
  
}