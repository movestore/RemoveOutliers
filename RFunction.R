library('move2')
library('units')
library('sf')
library('dplyr')

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

  if (is.null(maxspeed) & MBremove==FALSE & FUTUREremove==FALSE & (is.null(accuracy_var) | is.null(minaccuracy))) logger.info("No maximum speed provided, no accuracy variable/minimum accuracy defined and required to leave Movebank marked Outliers and future timestamp locations in. Return input data set.")
  
  if (!is.null(maxspeed)) logger.info(paste0("Remove positions with maximum speed > ", maxspeed,"m/s")) else logger.info ("No maximum speed provided, so no filtering by it.")
  if (MBremove==TRUE) logger.info("In Movebank marked outliers will be removed.") else logger.info("In Movebank marked outliers will be retained.")
  if (FUTUREremove==TRUE) logger.info("Locations with future timestamps will be removed.") else logger.info("Locations with future timestamps will be retained.")
  if (!is.null(accuracy_var) & !is.null(minaccuracy)) logger.info(paste("Remove positions with high location error:",accuracy_var,">",minaccuracy)) else logger.info("Data will not be filtered for location error.")

  #take out unrealistic coordinates
  ixNN <- which (st_coordinates(data)[,1]<(-180) | st_coordinates(data)[,1]>180 | st_coordinates(data)[,2]<(-90) | st_coordinates(data)[,2]>90)
  if (length(ixNN)>0)
  {
    logger.info(paste(length(ixNN),"locations have longitude/latitude outside of the usual ranges [-180,180],[-90,90]. Those locations are removed from the data set"))
    data <- data[-ixNN,] #if one complete animal is taken out, no problem with moveStack structure :)
  }
  
  data.split <- split(data,mt_track_id(data))
  clean <- lapply(data.split, function(datai) {
    #logger.info(unique(mt_track_id(datai)))
    datai<-datai %>% dplyr::filter(!st_is_empty(datai)) ## remove empty geometries because they cause an error
    if (MBremove==TRUE) 
    {
      ix <- which(as.logical(datai$visible)==FALSE) #all marked outliers go together in "visible"
      if (length(ix)>0)
      {
        logger.info(paste("For track",unique(mt_track_id(datai)), ":",length(ix),"in Movebank marked outliers were removed."))
        datai <- datai[-ix,]
      }
    }
    if (!is.null(accuracy_var) & !is.null(minaccuracy)) 
    {
      ixA <- which(as.numeric(as.data.frame(datai)[,accuracy_var])>=as.numeric(minaccuracy))
      if (length(ixA)>0)
      {
        logger.info(paste("For track",unique(mt_track_id(datai)), ":",length(ixA),"positions with high errors are removed:",accuracy_var,">",minaccuracy))
        datai <- datai[-ixA,]
      }
    }
    if (!is.null(maxspeed) & nrow(datai)>0) #here changed to while loop (Jan2024)
    {
      len0 <- nrow(datai)
      ixS <- 0
      while (any(units::set_units(mt_speed(datai),m/s)[-nrow(datai)]>units::set_units(maxspeed,m/s)))
      {
        if (length(datai)>1) ixS <- which(units::set_units(mt_speed(datai),m/s)>units::set_units(maxspeed,m/s)) else ixS <- numeric()  #fix for tracks with 1 locations
        if (length(ixS)>0) datai <- datai[-ixS,]
      }
      delN <- len0 - nrow(datai)
      if (delN>0) logger.info(paste("For track",unique(mt_track_id(datai)), ":",delN,"positions are removed due to between location speeds >",maxspeed,"m/s"))
    }
    datai
  })
  names(clean) <- names(data.split) #clean is still list of move objects
  if (length(clean)>1) clean_move2 <- mt_stack(clean,.track_combine = "rename") else clean_move2 <- clean[[1]]

  if (FUTUREremove==TRUE & nrow(clean_move2)>0)
  {
    time_now <- Sys.time()
    clean_nofuture <- lapply(clean, function(cleani) {
      logger.info(unique(mt_track_id(cleani)))
      if (any(mt_time(cleani)>time_now)) 
      {
        ix_future <- which(mt_time(cleani)>time_now)
        logger.info(paste("Warning! Data of the animal",unique(mt_track_id(cleani)),"contain",length(ix_future),"timestamps in the future. They are removed here."))
        cleani[-ix_future] 
      } else 
      {
        logger.info("There are no locations with timestamps in the future.")
        cleani
      }
    })
  } else clean_nofuture <- clean

  if (length(clean_nofuture)>1) result <- mt_stack(clean_nofuture,.track_combine="rename") else result <- clean_nofuture[[1]]
  
  if (nrow(result)==0)
  {
    logger.info("Your output file contains no positions. Return NULL.")
    result <- NULL
  }

  print(nrow(result))
  
  result
}
  
