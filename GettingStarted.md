## Getting Started with RGoogleAnalytics ##
This document describes how you can get started using the Google Analytics For R library.

## Overview ##
Follow these steps to access Google Analytics data using this library:
  1. Make sure your workspace can reference this library.
  1. Authorize this library to access your Google Analytics data.
  1. Identify the report profile you’ll use access data.
  1. Create API queries and work with the data returned from the API.

This guide describes each of these steps and shows you how to work with the data returned from the API.

## Reference the Library ##
First you must make sure that your workspace can access the functionality in this client library, which has been built to be run as a native R package. You can download the RGoogleAnalytics package from the [//code.google.com/p/r-google-analytics/downloads/list downloads] section of this project.

To install the package, use:
```
R CMD INSTALL RGoogleAnalytics_1.0.tar.gz
```

For more details on the terminology and installing packages, check the R documentation on [Add-On Packages](http://cran.r-project.org/doc/manuals/R-admin.html#Add_002don-packages).

Once you have the package installed, you can load it into your script using the library command:
```
library(RGoogleAnalytics)
```

## Using The Library ##
One you have the library loaded, there are 3 steps you use to get data from Google Analytics:

  1. Authorize this library to access your Google Analytics data.
  1. Determine the table ID of the profile you want to access to.
  1. Build a query and get the results from the API.

All of these tasks are encapsulated as separate functions which you can access by calling the `GoogleAnalyticsAPI` method:
```
ga <- GoogleAnalyticsAPI()
```

You can now use the functions in the `ga` variable to accomplish each task.

## Authorization ##
Just like you need to log into Google Analytics to access your data, you will need to use your Google Analytics username and password to grant this client library access to your data. This process is called `Authorization` and is handled using the `SetCredentials` method.
```
ga$SetCredentials(“USER_NAME”, “PASSWORD”)
```

Each parameter is a string and must be quoted. Once this function has completed successfully, you have authorized access to your Google Analytics account and are ready to go onto the next steps.

**Note**: This method should be called once in your script.  Make sure you are not calling it multiple times in a loop.

Under the hood, this client library uses the `ClientLogin` authorization method to grant access to your data. This method requests a Google Account username and password, and these credentials should have access to Google Analytics. It then uses the credentials to get an access token, which can be used with the Google Analytics API in place of the credentials. The access token is good for 14 days, so the client library saves it into memory and uses the token in each API request for data. For more information, see the [Google Data Client Login documentation](http://code.google.com/apis/gdata/docs/auth/clientlogin.html).

## Accessing Profile / Table Ids ##
All reports in Google Analytics are controlled by a profile. To query report data you need to identify a profile by specifying a profile’s table ID (e.g.  `ga:xxx`). The `GetProfileData` function returns a data frame of all the account names, profile names, and table IDs the authorized user has access to.
```
profiles <- ga$GetProfileData()
```
For more information about the relationship of accounts and profiles, see the [Accounts and Profiles reference document](http://code.google.com/apis/analytics/docs/concepts/gaConceptsAccounts.html).

Once you have the the Table ID, you are ready to query data from the API.

## Access Profile Data ##
This library provides access to the dimensions and metrics exposed by the Google Analytics Data Export API (currently over 170). To access this data you must first specify a query.

### Specifying Queries ###
Use the helpful `QueryBuilder` class to simplify creating a Data Export API query.

Here’s an example of how to use this class to request the daily visit and pageview metrics for all organic search traffic in the month of May:

```
query <- QueryBuilder()
query$Init(start.date = "2010-05-01",
           end.date   = "2010-05-31",
           dimensions = "ga:date",
           metrics    = "ga:visits,ga:pageviews",
           sort       = "ga:date",
           segment    = "dynamic::medium==organic",
           tableId    = "ga:xxx")
```

To modify a query once you’ve built it, use the cooresponding function for each query parameter. For example, to modify the `dimensions` query parameter to return countries and cities, you can use the `query.builder$dimensions` function:
```
query$dimensions("ga:country,ga:city”)
```
To see the query parameters value once it’s been set, use the corresponding function for each query parameter without any parameters. For example, to get the `dimensions` query parameter, you can use:
```
query$dimensions()
```
To remove a parameter from an existing query, set the value to `NULL`:
```
query.builder$dimensions(NULL)
```
If you want to see the final generated URL, use:
```
uri <- query$to.uri()
```
For a list of data available, see the [Dimensions and Metrics reference](http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDimensionsMetrics.html).
To see some more popular queries, check the [Common Queries guide](http://code.google.com/apis/analytics/docs/gdata/gdataCommonQueries.html).
Finally, use the [Interactive Query Explorer tool](http://code.google.com/apis/analytics/docs/gdata/gdataExplorer.html) to build your own queries.

Once you have constructed your query, you can use it to request data from the API.

### Requesting Data ###

Once you have a query object, you pass it as a parameter to the `GetReportData` method to request data from the API:
```
ga.data <- ga$GetReportData(query)
```

**Note**: that this function only accepts an instance of `QueryBuilder()`.

### Working With the Results ###
The data returned from the API can be thought of as a table, where each row is a combination of dimensions and metrics.

You can access the tabular data from the `ga.data` variable above using:
```
ga.data$data
```
For any query, the Google Analytics API might find more rows of data inside of Google Analytics than the API will return. To see the total number of rows of data found (not returned) use:
```
ga.data$total.results
```
You can access the sum of all the metrics (called the aggregates) for the matched rows using:
```
data$aggr.totals
```
See the [aggregates section of the Data Feed response](http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDataFeed.html#dataResponse) document to learn more about the aggregate data.

For some queries, the API samples data. In that case a new confidence interval column is added to the data frame. Read the [Sampling and Confidence Interval](http://code.google.com/apis/analytics/docs/gdata/gdataReferenceDataFeed.html#sampling) section of the data feed reference document to learn more about these values.

### Paginating Through Results ###
By default, each API request returns 1000 rows of data. This client library provides a built-in mechanism to auto-generate API requests to return up to 1 million rows of data.

To access more than 1,000 rows of data, specify the `max.rows` parameter in the API request:
```
ga.data <- ga$GetReportData(query, max.rows=1000000)
```
Using large values for max.rows will take a long time. So we recommend you run your R script in `BATCH` mode when requesting large amounts of data.
```
R CMD BATCH my_R_script.R
```