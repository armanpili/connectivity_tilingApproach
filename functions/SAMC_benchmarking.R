samc_benchmarking <- function(dataResistance, # raster for one tile or list to raster paths for many tiles
                              dataAbsorption,
                              dataInitiation,
                              transitionModel = list(fun = function(x) 1/mean(x), 
                                                     dir = 8,                     
                                                     sym = TRUE),
                              analysis = c("distribution",
                                           "mortality",
                                           "survival",
                                           "visitation",
                                           "visitation_net"),
                              domainExtent,
                              purgeExistingFiles = FALSE,
                              domainName,
                              experimentName,
                              nCores = 1,
                              outputFolder = "../output",
                              saveMeta = TRUE,
                              saveRaster = TRUE,
                              replicateNumber){
  
  require(terra)
  require(samc)
  require(foreach)
  require(doParallel)
  require(parallel)
  require(pryr)
  
  
  message("Case study: ", domainName)
  message("Analysing ", paste(analysis, collapse = ", "), " for ", length(dataResistance), " tile")  
  
  startTime <- Sys.time()  
  
  message("Start Time:", startTime)
  
  objectOutput <- list(
    domainName = domainName,
    experimentName = experimentName,
    nCores = nCores,
    nTiles = length(dataResistance),
    analysisOutput = list(),

    runtime = NA,
    replicate = replicateNumber)
  
  
  message(".......................................................0%")
  
  folderPaths <- c(outputFolder,
                   paste0(outputFolder, "/", domainName, "/", experimentName),
                   paste0(outputFolder, "/", domainName, "/", experimentName, "/", analysis))
  
  
  message("Purging all past files!")
  if (purgeExistingFiles == TRUE) {
    file.remove(list.files(folderPaths, 
                           pattern = ".tif", 
                           full.names = TRUE))
  } # end of data purging
  
  # PREPARING REPOSITORY
  
  message("Creating output folders")  
  for(i in folderPaths) {
    # Check if folder exists; if not, create it
    if (!dir.exists(i)) {
      dir.create(i, recursive = TRUE)
      message("Folder created: ", i)
    } else {
      message("Folder already exists: ", i)
    }
  } # end of folder creation
  
  message("=====..................................................10%")
  
  # LANDSCAPE-WIDE ANALYSIS
  #######################################################
  if(length(dataResistance) == 1) {
    
    
    message("Creating SAMC object")  
    samcObject <- samc(data = dataResistance, 
                       absorption = dataAbsorption,  
                       model = transitionModel)
    message("...Success!!!") 
    message("================================.......................50%")
    message("Anaysing SAMC object")
    for (i in analysis) {
      message("...", i)
      analysisObject <- do.call(i,
                                c(samc = samcObject,
                                  init = dataInitiation))
      analysisRaster <- samc::map(samcObject, 
                                  analysisObject)
      writeRaster(analysisRaster,
                  paste0(outputFolder, "/",
                         domainName, "/", 
                         experimentName, "/", 
                         i, "/", 
                         i, "_", replicateNumber, ".tif"),
                  overwrite = TRUE)
      
      if(saveRaster == FALSE){
        file.remove(paste0(outputFolder, "/",
                           domainName, "/", 
                           experimentName, "/", 
                           i, "/", 
                           i, "_", replicateNumber, ".tif"))
      }
      
      objectOutput$analysisOutput[[i]] <- paste0(outputFolder, "/", 
                                                 domainName, "/", 
                                                 experimentName, "/", 
                                                 i, "/", 
                                                 i, "_", replicateNumber, ".tif")
      message("......Success!!!") 
      

      
    } # end of landscape-wide analysis


  } # end of landscape-wide samc 
  ####################################################
  
  if(length(dataResistance) > 1) {
    message("Analysing tiles.")
    folderPaths <- c(paste0(outputFolder, "/", 
                            domainName, "/", 
                            experimentName, "/", 
                            analysis, 
                            "/temp"))
    for(i in folderPaths) {
      if (!dir.exists(i)) {
        dir.create(i)
        message("Folder created: ", i)
      } else {
        message("Folder already exists: ", i)
      } # end of folder creation
    } # end of folder creation
    file.remove(list.files(folderPaths, 
                           pattern = ".tif", 
                           full.names = TRUE))
    
    
    # CHUNKING
    #######################################################
    if(nCores == 1){
      foreach(j = 1:length(dataResistance)) %do% {
        message("... Tile ", j)  
        gc()
        message("..... Creating SAMC object")  
        samcObject <- samc(data = rast(dataResistance[j]), 
                           absorption = rast(dataAbsorption[j]),  
                           model = transitionModel)
        message(".........Success!!!") 
        message("......Anlaysing SAMC object")
        foreach(i = analysis) %do% {
          message(".........", i)
          analysisObject <- do.call(i,
                                    c(samc = samcObject,
                                      init = rast(dataInitiation[j])))
          analysisRaster <- samc::map(samcObject,
                                      analysisObject)
          writeRaster(analysisRaster,
                      paste0(outputFolder, "/", 
                             domainName, "/", 
                             experimentName, "/", 
                             i, "/temp/",
                             i,"_", j,".tif"))
          message("............Success!!!") 
        } # analysis
      } # end of SAMC
    } # end of tiling no cores
    
    
    #######################################################
    if(nCores > 1){
      
      message("...Parallelising with ", nCores, " cores!!!") 
      
      cl <- makeCluster(nCores)
      registerDoParallel(cl)
      
      foreach(j = seq_along(dataResistance), 
              .packages = c("samc", 
                            "terra")) %dopar% {
                              
                              
                              samcObject <- samc(data = rast(dataResistance[j]), 
                                                 absorption = rast(dataAbsorption[j]),  
                                                 model = transitionModel)
                              
                              for(i in analysis) {
                                analysisObject <- do.call(i,
                                                          c(samc = samcObject,
                                                            init = rast(dataInitiation[j])))
                                analysisRaster <- samc::map(samcObject,
                                                            analysisObject)
                                writeRaster(analysisRaster,
                                            paste0(outputFolder, "/", 
                                                   domainName, "/", 
                                                   experimentName, "/", 
                                                   i, "/temp/",
                                                   i,"_", j,".tif"))
                              } # analysis
                              
                            } # end of SAMC
      
      stopCluster(cl)
      
      message("...... Tiling success!!!") 
      
    } # end of tiling with cores
    
    
    #######################################################
    message("================================================.......80%")      
    
    # MERGING TILE OUTPUTS 
    
    message("... Merging maps.")
    
    for(k in analysis) {
      
      tempRast <- list.files(paste0(outputFolder, "/", 
                                    domainName, "/",
                                    experimentName, "/",
                                    k, "/temp/"),
                             pattern = ".tif",
                             full.names = TRUE
      )
      
      analysisRaster <- rast()
      
      for (l in tempRast) {
        analysisRaster <- c(analysisRaster,
                            terra::extend(x = rast(l),
                                          y = domainExtent, 
                                          fill = NA))
        analysisRaster <- sum(analysisRaster, na.rm = TRUE)
      }
      writeRaster(analysisRaster,
                  paste0(outputFolder, "/", 
                         domainName, "/", 
                         experimentName, "/", 
                         k, "/",
                         k, "_", replicateNumber, ".tif"),
                  overwrite = TRUE)
      
      if(saveRaster == FALSE){
        file.remove(paste0(outputFolder, "/", 
                           domainName, "/", 
                           experimentName, "/", 
                           k, "/",
                           k, "_", replicateNumber, ".tif"))
      }
      
      
      objectOutput$analysisOutput[[k]] <- paste0(outputFolder, "/", 
                                                 domainName, "/", 
                                                 experimentName, "/", 
                                                 k, "/",
                                                 k, "_", replicateNumber, ".tif")
      
      file.remove(list.files(paste0(outputFolder, "/", 
                                    domainName, "/", 
                                    experimentName, "/", 
                                    k, "/temp/"),
                             pattern = ".tif",
                             full.names = TRUE
      ))
    } # end of analysis output merging  
    
#    Rprof(NULL)
    
  } # end of tiling
  #######################################################
  
  
  message("===================================================....90%")  
  
  # LAST FEW THINGS
  
  ## RUNTIME 
  endTime <- Sys.time()
  
  message("Elapsed time: ",round(endTime - startTime, 4))
  
  objectOutput$runtime <- as.numeric(endTime - startTime, units = "secs")
  
  
  if(saveMeta == TRUE) {
    saveRDS(object = objectOutput, 
            file = paste0(outputFolder, "/", 
                          domainName, "/", 
                          experimentName, "/",
                          experimentName, "_", replicateNumber, ".rds")
    )
  } # end of file saving
  


  
  return(objectOutput)
  
} # end of samc_benchmarking function