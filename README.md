# Remove Outliers
MoveApps

Github repository: *github.com/movestore/RemoveOutliers*

## Description
Remove location records from a tracking data set that should be considered "outliers" in the context of the workflow. These include locations that fall outside the range W180-E180 and S90-N90, and can be further defined as locations that exceed a user-defined speed, that have been marked as outliers in Movebank, that have a timestamp in the future, or that exceed a user-specified location error threshold.

## Documentation
This App is designed to remove outliers from your data set prior to subsequent analysis steps. First, it removes any locations with longitude/latitude outside of the defined ranges -180 to 180 (longitude) and -90 to 90 (latitude). Then, based on user-provided settings, it can optionally remove
* locations that exceed a speed threshold (approximated between-location speed)
* locations defined as outliers in Movebank, which are indicated by the variable [visible](http://vocab.nerc.ac.uk/collection/MVB/current/MVB000209/) being `FALSE` (see note below). 
* locations for which the timestamp is in the future (these can be inaccurate values recorded by tags; otherwise, also check whether these may indicate a problem in your data)
* locations in which values in an attribute that contains a location accuracy estimate exceed a ceratin value.* Note that it will lead to an error, if the selected attribute contains values that are not numeric. If that is the case for your data, dont use this feature.

**Note:** If these data are from a study in Movebank for which you are a data manager, and if you want to flag records that you consider to be outliers across most/all use cases, we recommend [flagging outliers directly in the study](https://www.movebank.org/cms/movebank-content/upload-qc#flag_outliers) where possible. By storing results in your study, you will avoid needing to replicate these filter steps across workflows or other software, and can indicate those records you consider to be outliers to anyone with whom you share your data.

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
none

### Settings
**Speed exceeding movement abilities of the animal(s) (`maxspeed`):** Maximum ground speed that the animals are capable of moving. Unit: m/s. Example: 50.

**Movebank marked Outliers (`MBremove`):** Indication if Movebank defined outliers shall be removed. Checkbox (Yes/No)

**Future timestamp Outliers (`FUTUREremove`):** Indication if future timestamps shall be removed. Checkbox (Yes/No)

**Name of variable indicating location error (`accuracy_var`):** Name of the data attribute that indicates location error. Please be very accurate in spelling. Example. "location_error_numerical".

**Maximum acceptable location error (`minaccuracy`):** Minimum accuracy that is required for useful data, in the units of the chosen location error attribute. Locations exceeding this value will be removed from the data set. This related to the user-defined `accuracy_var`. Example: 30

### Null or error handling:
**Setting `maxspeed`:** If no maximum speed is given (NULL), then the locations are not filtered for this property. 

**Setting `MBremove`:** This value can only be Yes or No, so no error or null possible.

**Setting `FUTUREremove`:** This value can only be Yes or No, so no error or null possible.

**Setting `accuracy_var`:** If this variable name is not given or does not fit with any of the data attributes, the data will not be filtered for accuracy.

**Setting `minaccuracy`:** If this value is not given (NULL), the data will not be filtered for accuracy.

**Data:** If no data are retained after all outlier removal, NULL is returned, likely leading to an error.
