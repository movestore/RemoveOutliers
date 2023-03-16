# Remove Outliers
MoveApps

Github repository: *github.com/movestore/RemoveOutliers*

## Description
Different types of outliers can be removed from a Movement data set: any locations that exceed a user-given speed, that have been marked as outliers in Movebank, that have an unrealistic, future timestamp or that exceed a user-specified error attribute.

## Documentation
This App is designed to delete outliers from your data set before any analysis. First, it deletes any locations with longitude/latitude outside of the defined ranges -180 to 180 (longitude) and -90 to 90 (latitude). Then, it filters out the Movebank defined outliers, which are indicated by the variable `visible` being `FALSE`. Furthermore, it allows removing locations to which a user-given speed is exceeded. Also tag specific accuracy variable can be defined and taken out if exceeding a ceratin value. Finally, locations with timestamps that lie in the future can be removed.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
none

### Settings
**Speed exceeding movement abilities of the animal(s) (`maxspeed`):** Maximum ground speed that the animals are capable of moving. Unit: m/s Example: 50.

**Movebank marked Outliers (`MBremove`):** Indication if Movebank defined outliers shall be removed. Checkbox (Yes/No)

**Future timestamp Outliers (`FUTUREremove`):** Indication if future timestamps shall be removed. Checkbox (Yes/No)

**Name of variable indicating location error (`accuracy_var`):** Name of the data attribute that indicates location errors. Please be very accurate in spelling. Example. "location_error_numerical".

**Maximum acceptable location error (`minaccuracy`):** Minimum accuracy that is required for useful data. Exceeding this value leads to location removal. This related tot he user-defined `accuracy_var`. Example: 30

### Null or error handling:
**Setting `maxspeed`:** If no maximum speed is given (NULL), then the locations are not filtered for this property. 

**Setting `MBremove`:** This value can only be Yes or No, so no error or null possible.

**Setting `FUTUREremove`:** This value can only be Yes or No, so no error or null possible.

**Setting `accuracy_var`:** If this variable name is not given or does not fit with any of the data attributes, the data will not be filtered for accuracy.

**Setting `minaccuracy`:** If this value is not given (NULL), the data will not be filtered for accuracy.

**Data:** If no data are retained after all outlier removal, NULL is returned, likely leading to an error.
