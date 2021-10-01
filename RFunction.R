library('move')

rFunction <- function(data, maxspeed=NULL, MBremove=TRUE, FUTUREremove=TRUE, accuracy_var=NULL, minaccuracy=NULL)
{
  Sys.setenv(tz="UTC") 
  
  if (!is.null(accuracy_var))
  {
    if (accuracy_var %in% names(data)==FALSE)
    {
    logger.info("Your defined accuracy variable name does not exist in the data. Please double check. Here it is set to NULL, leading to no removal of high error locations.")
    accuracy_var <- NULL
    }
  }
  #print(accuracy_var)
  
  if (is.null(maxspeed) & MBremove==FALSE & FUTUREremove==FALSE & (is.null(accuracy_var) | is.null(minaccuracy))) logger.info("No maximum speed provided, no accuracy variable/minimum accuracy defined and required to leave Movebank marked Outliers and future timestamp locations in. Return input data set.")
  
  if (!is.null(maxspeed)) logger.info(paste0("Remove positions with maximum speed > ", maxspeed,"m/s")) else logger.info ("No maximum speed provided, so no filtering by it.")
  if (MBremove==TRUE) logger.info("In Movebank marked outliers will be removed.") else logger.info("In Movebank marked outliers will be retained.")
  if (FUTUREremove==TRUE) logger.info("Locations with future timestamps will be removed.") else logger.info("Locations with future timestamps will be retained.")
  if (!is.null(accuracy_var) & !is.null(minaccuracy)) logger.info(paste("Remove positions with high location error:",accuracy_var,">",minaccuracy)) else logger.info("Data will not be filtered for location error.")

  data.split <- move::split(data)
  clean <- lapply(data.split, function(datai) {
    logger.info(namesIndiv(datai))
    if (MBremove==TRUE) 
    {
      ix <- which(as.logical(datai$visible)==FALSE) #all marked outliers go together in "visible"
      logger.info(paste("For this animal",length(ix),"in Movebank marked outliers were removed."))
      if (length(ix)>0) datai <- datai[-ix,]
    }
    if (!is.null(accuracy_var) & !is.null(minaccuracy)) 
    {
      ixA <- which(datai@data[,accuracy_var]>=as.numeric(minaccuracy))
      logger.info(paste("For this animal",length(ixA),"positions with high errors are removed:",accuracy_var,">",minaccuracy))
      if (length(ixA)>0) datai <- datai[-ixA,] 
    }
    if (!is.null(maxspeed)) 
    {
      ixS <- which(speed(datai)>maxspeed)  
      logger.info(paste("For this animal",length(ixS),"positions are removed due to between location speeds >",maxspeed,"m/s"))
      if (length(ixS)>0) datai <- datai[-ixS,]
    }
    datai
  })
  names(clean) <- names(data.split) #clean is still list of move objects

  if (FUTUREremove==TRUE)
  {
    time_now <- Sys.time()
    clean_nofuture <- lapply(clean, function(cleani) {
      logger.info(namesIndiv(cleani))
      if (any(timestamps(cleani)>time_now)) 
      {
        ix_future <- which(timestamps(cleani)>time_now)
        logger.info(paste("Warning! Data of the animal",namesIndiv(cleani),"contain",length(ix_future),"timestamps in the future. They are removed here."))
        cleani[-ix_future] 
      } else 
      {
        logger.info("There are no locations with timestamps in the future.")
        cleani
      }
    })
  } else clean_nofuture <- clean

  
  clean_nozero <- clean_nofuture[unlist(lapply(clean_nofuture, length) > 0)] #remove list elements of length 0
  if (length(clean_nozero)==0) 
  {
    logger.info("Your output file contains no positions. Return NULL.")
    result <- NULL
  } else result <- moveStack(clean_nozero)

  result
}
  
