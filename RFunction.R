library('move')
library('foreach')

rFunction <- function(data, maxspeed=NULL, MBremove=TRUE, FUTUREremove=TRUE, accuracy_var=NULL, minaccuracy=NULL)
{
  Sys.setenv(tz="GMT") 
  
  if (accuracy_var %in% names(data)==FALSE)
  {
    logger.info("Your defined accuracy variable name does not exist in the data. Please double check. Here set it to NULL")
    accuracy_var <- NULL
  }
  
  if (is.null(maxspeed) & MBremove==FALSE & FUTUREremove==FALSE & (is.null(accuracy_var) | is.null(minaccuracy))) logger.info("No maximum speed provided, no accuracy variable/minimum accuracy defined and required to leave Movebank marked Outliers and future timestamp locations in. Return input data set.")
  
  if (!is.null(maxspeed)) logger.info(paste0("Remove positions with maximum speed > ", maxspeed,"m/s"))
  if (MBremove==TRUE) logger.info("In Movebank marked outliers will be removed.")
  if (!is.null(accuracy_var) & !is.null(minaccuracy)) logger.info(paste("Remove positions with high location error:",accuracy_var,">",minaccuracy))

  data.split <- move::split(data)
  clean <- foreach(datai = data.split) %do% {
    logger.info(namesIndiv(datai))
    if (MBremove==TRUE) 
    {
      ix <- which(as.logical(datai$visible)==FALSE) #all marked outliers go together in "visible"
      if (length(ix)>0) 
      {
        logger.info(paste("For this animals",length(ix),"in Movebank marked outliers were removed for animal",namesIndiv(datai)))
        datai <- datai[-ix,]
      }
    }
    if (!is.null(accuracy_var) & !is.null(minaccuracy)) 
      {
        ixA <- which(datai@data[,accuracy_var]>=as.numeric(minaccuracy))
        if (length(ixA)>0)
        {
          logger.info(paste("For this animal",length(ixA),"positions with high errors are removed:",accuracy_var,">",minaccuracy))
          datai <- datai[-ixA,] 
        }
      }
    if (!is.null(maxspeed)) 
      {
        ixS <- which(speed(datai)>maxspeed)  
        logger.info(paste("For this animal",length(ixS),"positions are removed due to between location speeds >",maxspeed,"m/s"))
        datai <- datai[-ixS,]
    }
    datai
  }
  names(clean) <- names(data.split) #clean is still list of move objects

  if (FUTUREremove==TRUE)
  {
    time_now <- Sys.time()
    clean_nofuture <- foreach(cleani = clean) %do% {
      if (any(timestamps(cleani)>time_now)) 
      {
        ix_future <- which(timestamps(cleani)>time_now)
        logger.info(paste("Warning! Data of the animal",namesIndiv(cleani),"contain",length(ix_future),"timestamps in the future. They are removed here."))
        cleani[-ix_future] 
      } else cleani
    }
  } else clean_nofuture <- clean

  
  clean_nozero <- clean_nofuture[unlist(lapply(clean_nofuture, length) > 0)] #remove list elements of length 0
  if (length(clean_nozero)==0) 
  {
    logger.info("Your output file contains no positions. Return NULL.")
    result <- NULL
  } else result <- moveStack(clean_nozero)

  result
}
  
