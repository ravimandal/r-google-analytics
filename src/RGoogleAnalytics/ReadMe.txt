This document describes how you can get started using the Google Analytics for R library.

How to install this R package in R:

This package depends on 2 libraries.
	
	a. RCurl - provides https support from within R. You can install the package from within R using:
		install.packages("RCurl") or http://cran.r-project.org/web/packages/RCurl/index.html
     
	b. rjson - provides support to parse the JSON response from the API. You can install the package from within R using:
		install.packages("rjson") or http://cran.r-project.org/web/packages/rjson/index.html

	If errors occur when downloading/installing Rcurl or rjson packages, ensure the libcurl library is up to date.
	On a Linux machine, you can run:
		$ sudo apt-get install libcurl4-gnutls-dev

Install the R package: 

	From Local repository:- 
	For installing from the local directory, you need to doenlad this R package as per your Operating system.                      
                          	
		Windows user:
	              Download this R package in Zip format
	 
		In R studio:
		Packages > Install packages >> 
										Select the following 
										1. Inastall from :: Package Archieve File (ZIP)
										2. Package Archieve :: Browser by the location of the zip file of the R package 
								   
										>> Install  

		Linux user:
	              Download this R package in tar.gz format
				  
		Packages > Install packages >> 
										Select the following 
										1. Inastall from :: Package Archieve File (tar.gz)
										2. Package Archieve :: Browser by the location of the zip file of the R package 
								   
										>> Install  
								 
								 
Getting Started: 

Once everything is configured it's a snap to get Google Analytics Data! 
Here's an Example for RGoogleAnalytics version 1.4:

# Loading the RGoogleAnalytics library
require("RGoogleAnalytics")

# Step 1. Authorize your account and paste the accesstoken 
query <- QueryBuilder()
access_token <- query$authorize()                                                

# Step 2. Initialize the configuration object
conf <- Configuration()

# Retrieving a list of Accounts
ga.account <- conf$GetAccounts() 
ga.account

# Retrieving a list of Web Properties
# With passing parameter as (ga.account$id[index]) will retrieve list of web properties under that account 
ga.webProperty <- conf$GetWebProperty()
ga.webProperty

# Retrieving a list of web profiles available for specific Google Analytics account and Web property
# by passing with two parameters - (ga.account$id,ga.webProperty$id).
# With passing No parameters will retrieve all of web profiles
ga.webProfile <- conf$GetWebProfile(ga.account$id[4],ga.webProperty$id[5])
ga.webProfile

# Retrieving a list of Goals
# With passing three parameters (ga.account$id[index],ga.webProperty$id[index], ga.webProfile$id[index])
# will retrieve specific goals
ga.goals <- conf$GetGoals()
ga.goals

# For retrieving a list of Advanced segments
ga.segments <- conf$GetSegments()
ga.segments

# Step 3. Create a new Google Analytics API object
ga <- RGoogleAnalytics()

# Old way to retrieve profiles from Google Analytics 
ga.profiles <- ga$GetProfileData(access_token)

# List the GA profiles 
ga.profiles

# Step 4. Setting up the input parameters
profile <- ga.profiles$id[3] 
startdate <- "2012-12-18"
enddate <- "2013-09-28"
dimension <- "ga:date,ga:source,ga:pageTitle,ga:pagePath"
metric <- "ga:visits"
#filter <- 
segment <- ga.segments$segmentId[8]
sort <- "ga:visits"
maxresults <- 99

# Step 5. Build the query string, use the profile by setting its index value 
query$Init(start.date = startdate,
           end.date = enddate,
           dimensions = dimension,
           metrics = metric,
           #sort = sort,
           #filters="",
           segment=segment,
           max.results = maxresults,
           table.id = paste("ga:",profile,sep="",collapse=","),
           access_token=access_token)

# Step 6. Make a request to get the data from the API
ga.data <- ga$GetReportData(query)

# Look at the returned data
head(ga.data)
================================================================================

Here's an Example:(based on version 1.3)

# Loading the RGoogleAnalytics library
require("RGoogleAnalytics")

# 1. Authorize your account and paste the accesstoken 
query <- QueryBuilder()
access_token <- query$authorize()								 

# 2.  Create a new Google Analytics API object
ga <- RGoogleAnalytics()
ga.profiles <- ga$GetProfileData(access_token)

# List the GA profiles 
ga.profiles

# 3. Build the query string, use the profile by setting its index value 
query$Init(start.date = "2012-06-18",
           end.date = "2012-12-18",
           dimensions = "ga:date,ga:pagePath",
           metrics = "ga:visits,ga:pageviews,ga:timeOnPage",
           sort = "ga:visits",
           #filters="",
           #segment="",
           max.results = 99,
           table.id = paste("ga:",ga.profiles$id[1],sep="",collapse=","),
           access_token=access_token)

# 4. Make a request to get the data from the API
ga.data <- ga$GetReportData(query)

# 5. Look at the returned data
head(ga.data)


================================================================================
#To Run unit test, follow the steps 
# 1. Update the path of two files QueryBuilder.R, RGoogleAnalytics.R in both of 
     the unit test files - QueryBuilder_unittest.R and RGoogleAnalytics_unittest.R
# 2. Update the value od the dirs variable as the path to RGoogleAnalytics/test 
     folder in RUnit_driver.R file.
# 3. Run the RUnit_driver.R file to execute all test cases exists in R files.

#Additional Reference Information:
# https://developers.google.com/analytics/devguides/config/mgmt/v3/
# https://developers.google.com/analytics/devguides/reporting/core/v3/reference
# http://code.google.com/p/r-google-analytics/wiki/GettingStarted
