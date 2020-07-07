library('move')
library('foreach')

rFunction <- function(data, maxspeed=NULL)
{
  Sys.setenv(tz="GMT") 
  
  if (is.null(maxspeed)) logger.info("No maximum speed provided, only manually marked Outliers removed.") else logger.info(paste0("Remove manually marked outliers and positions with maximum speed > ", maxspeed,"m/s"))
  
  data.split <- move::split(data)
  clean <- foreach(datai = data.split) %do% {
    logger.info(namesIndiv(datai))
    datai <- datai[(is.na(datai@data$manually_marked_outlier) | datai@data$manually_marked_outlier==""),]
    if (!is.null(maxspeed)) datai[speed(datai)<maxspeed,] else datai
  }
  names(clean) <- names(data.split)
  
  clean_nozero <- clean[unlist(lapply(clean, length) > 1)] #remove list elements of length 1 or 0
  moveStack(clean_nozero)
}
  
