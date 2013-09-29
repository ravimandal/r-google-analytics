\name{Configuration}

\alias{Configuration}


\title{ For retrieving the Configuration data.}

\description{This class includes several methods for retrieving various configuration elements like Accouts,
 WebProperty, WebProfiles, Goals, Customsource and Segments. }

\value{
GetAccounts() - To retrieve all Google Analytics accounts to which the user has access.

GetWebProperty() - To retrieve the list of Web Properties available under Google Analytics Accounts.

GetWebProfile() - To retrieve the list of Web Profiles available under Google Analytics Web Property.

GetGoals() - To retrieve the Goals creted under Google Analytics Webprofiles as well as Google Analytics Web Property and Google Analytics Accounts.

GetSegments() - To retrieve the list of user's advance segments or custom segments created under user account.

GetCustomSource() - To retrieve the list of Custom Data Sources created under Google Analytics Account and Web Property.
}
\references{
For more information visit,
1. \link{https://code.google.com/p/r-google-analytics}

2. \link{https://developers.google.com/analytics/devguides/config/mgmt/v3/#concepts}
}


\examples{

## Examples on How to use Configuration 

# Creating the object of this Configuration class
conf <- Configuration()

## For retrieving the Google Analytics Account
ga.account <- conf$GetAccounts() 

## For retrieving the Google Analytics Web Property
# For retrieving all of the web property
ga.webProperty <- conf$GetWebProperty()

# For retrieving the web property available for specific Google Analytics account
ga.webProperty <- conf$GetWebProperty(ga.account$id[2])

## For retrieving the Google Analytics Profiles
# For retrieving all of the web profiles available
ga.webProfile <- conf$GetWebProfile()

# For retrieving the web profiles available for specific Google Analytics account and Web property
ga.webProfile <- conf$GetWebProfile(ga.account$id[4],ga.webProperty$id[5])

## For retrieving the Google Analytics Goals
# For retrieving the Goals from Google Analytics 
ga.goals <- conf$GetGoals()

# For retrieving the goals from specif account and/or web property and/or profile.
ga.goals <- conf$GetGoals()
ga.goals <- conf$GetGoals(ga.account$id[4],ga.webProperty$id[5],ga.webProfile$id[5])

## For retrieving the Google Analytics custome data source
# For retrieving the Google Analytics custom data source
ga.customeDataSource <- conf$GetCustomSource(ga.account$id[3],ga.webProperty$id[4])

## For retrieving the Google Analytics segments
ga.segments <- conf$GetSegments()

}