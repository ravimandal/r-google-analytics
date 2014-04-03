README

New Features:

1. Authorization Process has been updated. The user is required to create a Project in 
   the Google API Developer Console and register a new app. Create a new Client ID for the Application Type
   "Installed App". This however requires the Analytics API to be enabled. Once the App is successfully 
   registered, the Client ID and Client Secret would be used in the RGoogleAnalytics authorization flow.

2. The Client ID and Client Secret are saved locally to a file so that the user does not have to re-enter the 
   credentials every time. This file can also be deleted if necessary.

2. Post successful Account Authentication, the Access and Refresh Tokens are saved locally to a system file.
   This ensures that a new Access Token can be generated automatically once the older one expires. 
   Users no longer have to manually generate new Access Tokens every hour.

3. Implemented Query Pagination in order to retrieve more than 10000 rows of data 

4. Implemented Daywise Query Partitioning in order to decrease the effect of Sampling

5. More informative and user friendly status Messages

6. In case of queries where data is Sampled, the Percentage Visits for Sampled Query is calculated and displayed 
   to the user

Changes to Existing Features

1. Since Access Token is stored in a local file, these tokens no longer need to be passed as function arguments.
   This ensures that the user does not accidentally modify the access token and results in more cleaner code

2. The user does not need to retrieve the list of Profiles for the Analytics Account while initializing the query.
   The user can directly enter the Profile ID of the account which is to be queried. This is mapped to the table.id 
   argument in the query$Init() function

3. Functions of the RGoogleAnalytics() object could modify internal variables in the QueryBuilder() object. For eg. in 
   the earlier code the start.index variable of QueryBuilder() object was dynamically modified during Pagination. This is 
   now being done via SetStartIndex() function rather than modifying the variable directly. A similar approach has been followed
   for Start Date and End Date variables
