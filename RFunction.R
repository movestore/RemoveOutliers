library('move')
library('foreach')

rFunction <- function(data, maxspeed=NULL, MBremove=TRUE)
{
  Sys.setenv(tz="GMT") 
  
  if (is.null(maxspeed)) 
  {
    if (MBremove==TRUE) logger.info("No maximum speed provided, but in Movebank marked Outliers removed.") else logger.info("No maximum speed provided and required to leave Movebank marked Outliers in. Return input data set.")
  } else 
  {
    if (MBremove==TRUE) logger.info(paste0("Remove positions with maximum speed > ", maxspeed,"m/s and in Movebank marked Outliers.")) else logger.info(paste0("Remove positions with maximum speed > ", maxspeed,"m/s, but as requested leave Movebank marked outliers in."))
  }
  
  data.split <- move::split(data)
  clean <- foreach(datai = data.split) %do% {
    logger.info(namesIndiv(datai))
    if (MBremove==TRUE) datai <- datai[as.logical(datai$visible)==TRUE,] else datai <- datai #all marked outliers go together in "visible"
    if (!is.null(maxspeed)) datai[speed(datai)<maxspeed,] else datai
  }
  names(clean) <- names(data.split)

  clean_nozero <- clean[unlist(lapply(clean, length) > 0)] #remove list elements of length 0
  moveStack(clean_nozero)
}
  
