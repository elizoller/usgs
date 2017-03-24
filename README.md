# USGS Water Data Harvest

This ruby script reaches out to the USGS water site service API endpoint to get back each of the site codes. Because of the limitations in the API responses, we think it is best to use the site code as the main leading point to start getting the data.

There are multiple APIs which can return data based on the site code: instantaneous values, daily values, and statistics.[More info on the services](https://waterservices.usgs.gov/rest/)

We suggest getting data by specific dates to avoid hitting the 100,000 cap.

The code should be commented enough to create a starting point for this work.
