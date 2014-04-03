RGoogleAnalytics <- function() {
  # Creates a skeleton shell for accessing the Google Analytics API.
  #
  # Returns:
  #   Returns a list of methods, for accessing the Google Analytics API.
  #       GetProfileData()       
  #       GetReportData()       
  #       GetAppCredentials()
  #       RemoveToken()
  #       RemoveAppCredentials()
  #       ValidateToken()
  #       GenerateAccessToken()
  #       RefreshToAccessToken()
  #       
  # For more information please look at the help pages for each function.
  # Examples:
  # Step: 1. Authorize your account and paste the accesstoken 
  #    query <- QueryBuilder()
  #                     
  # Step: 2. Create a new Google Analytics API object
  #    ga <- RGoogleAnalytics()
  #    
  # Step: 3. Build the query string, use the profile adding the Profile ID in 
  # the table ID parameter 
  #    query$Init(start.date = "2011-06-18",
  #               end.date = "2012-12-18",
  #               dimensions = "ga:date, ga:pagePath",
  #               metrics = "ga:visits, ga:pageviews, ga:timeOnPage",
  #               sort = "ga:visits",
  #               #filters = "",
  #               #segment = "",
  #               max.results = 10000,
  #               table.id = )
  # Step: 4. Make a request to get the data from the API
  #    ga.data <- ga$GetReportData(query)
  # Step: 5. Look at the returned data
  #    head(ga.data)
  
  # Constant 
  kMaxDefaultRows <- 10000 
  kMaxPages <- 100
  
  # We have used oauth 2.0 API to authorize the user account 
  # and to get the accesstoken to request to the Google Analytics Data API. 
  query.uri <- NULL
  dataframe.param <- data.frame()
  
  # Set the CURL options for Windows    
  options(RCurlOptions = list(capath = system.file("CurlSSL",
                                                   "cacert.pem", 
                                                   package = "RCurl"),
                              ssl.verifypeer = FALSE))
  
  
  GetAppCredentials <- function(client_id,
                                client_secret) {
    # This function gets the Client ID and Client Secret of the Application from
    # the user and saves it locally to a file for OAuth 2.0 Authorization flow
    # Args:
    #  client_id : Client ID of the Application 
    #  client_secret : Client Secret of the Application
    # Returns:
    #  Saves the App Credentials to a file on the user's system 
    
    
    if(file.exists(file.path(system.file(package = "RGoogleAnalytics"),
                             "app_credentials.rda"))) {
      stop(cat("Your Application Credentials are already saved to your system. 
               Please use the RemoveAppCredentials Function to delete the credentials\n"))
    }
    
    #Argument Validation
    if (missing(client_id)) {
      stop(cat("Please specify a Client ID in the function arguments"))
    }
    
    if (missing(client_secret)) {
      stop(cat("Please specify a Client Secret in the function arguments"))
    }
    client.id <- as.character(client_id)
    client.secret <- as.character(client_secret)
    
    save(client_id,
         client_secret,
         file = file.path(system.file(package = "RGoogleAnalytics"),
                          "app_credentials.rda"))
    file_path <- as.character(file.path(system.file(package = "RGoogleAnalytics"),
                                        "app_credentials.rda"))
    cat("Your App Credentials have been saved to",file_path,"\n")
    }
  
  GenerateAccessToken <- function() {
    # When evaluated for the first time this function asks for User Consent
    # for the Google Analytics Account and retrieves the Access and Refresh Tokens
    # for Authorization. These tokens are saved locally to a file on the user's system.
    # If the user had authorized an account earlier and refresh token is already found
    # on the user's system, then this function retrives a new Access Token and updates
    # the Access Token File in user's memory.
    #
    # Args: 
    #  None
    # Returns : 
    #  Access Token : Character String representing the access token
    # ######Does not require explicit return value since token is no
    # ######longer stored in external environment
    
    #Check if the Access Token File already exists
    if(!file.exists(file.path(system.file(package="RGoogleAnalytics"),
                              "accesstoken.rda"))) {
      #File Does not exist
      #Check if API_Creds exists
      if(!file.exists(file.path(system.file(package="RGoogleAnalytics"),
                                "app_credentials.rda"))) {
        stop(cat("Application Credentials do not exist.Please use the GetAppCredentials 
                 function to save the credentials to a local file"))
      } else {
        
        #API Credentials file exists  
        #Load the app_credentials file
        load(file.path(system.file(package = "RGoogleAnalytics"),
                       "api_credentials.rda"))
        
        #Build the URL string
        client_id <- as.character(client_id) 
        client_secret <- as.character(client_secret)
        redirecturi <- "urn:ietf:wg:oauth:2.0:oob"
        
        url <- paste('https://accounts.google.com/o/oauth2/auth?',
                     'scope=https://www.googleapis.com/auth/analytics.readonly&',          
                     'state=%2Fprofile&',
                     'redirect_uri=', redirecturi, '&',
                     'response_type=code&',
                     'client_id=', client_id, '&',
                     'approval_prompt=force&',
                     'access_type=offline', 
                     sep = '',
                     collapse = '')
        
        #Get Auth Code
        # Load the prepared URL into a WWW browser.
        browseURL(url) 
        cat("The Google Analytics data extraction process requires an authorization code.",
            "To accept the authorization code, you need to follow certain steps in your ",
            "browser. This code will help this R packge to generate the access",
            "token. Make sure you have already supplied credentials for installed app.",
            "\n\nSteps to be followed : \n1. Authorize your",
            "Google Analytics account by providing email and password. \n ",
            "\n2. Copy the generated code.")
        
        code <- readline(as.character(cat("\n\nPaste the authorization code here",
                                          ":=>")))
        
        #Add some messages here
        cat("Retrieving the Access and Refresh Tokens based on the Authorization Code\n")
        
        # For retrieving the access token.
        accesstoken.list <- fromJSON(postForm('https://accounts.google.com/o/oauth2/token',
                                              code = code,
                                              client_id = client_id, 
                                              client_secret = client_secret,
                                              redirect_uri = redirecturi,
                                              grant_type = "authorization_code",
                                              style = "POST"))
        
        # For saving the generated access token (as List data type with 
        # values - access_token, token_type, expires_in and refresh_token)
        # in file system where RGoogleAnalytics package located.
        
        access_token <- accesstoken.list$access_token 
        
        save(accesstoken.list, 
             file = file.path(system.file(package = "RGoogleAnalytics"),
                              "accesstoken.rda"))
        
        access_token_file_path <- as.character(file.path(system.file(package = "RGoogleAnalytics"),
                                                         "accesstoken.rda"))                 
        
        cat("Access token has been saved to",access_token_file_path,"\n")
        
        return(access_token)
      }
      
    } else {
      #Load the Access Token from the file saved to the system
      
      load(file.path(system.file(package = "RGoogleAnalytics"),
                     "accesstoken.rda"))
      load(file.path(system.file(package = "RGoogleAnalytics"),
                     "api_credentials.rda"))
      
      #Get new Access Token
      access_token <- RefreshToAccessToken(accesstoken.list$refresh_token,client_id,client_secret)
      
      cat("Access token has been regenerated\n")
      
      return (access_token)
    }
  }
  
  RefreshToAccessToken <- function(refresh.token,client_id,client_secret){
    # This function takes the Refresh Token as an argument and retrives a new 
    # Access Token based on it
    # Reference : https://developers.google.com/accounts/docs/OAuth2#installed
    # Args :
    #   refresh.token : Refresh Token that was saved to the local file
    #   Client ID     : Client ID of the Application. This is a OAuth2.0 Credential
    #   Client Secret : Client Secret of the Application. Again this too is an
    #                   OAuth2.0 Credential
    # Returns :
    #   Access Token  : New Access Token 
    
    refresh.token.list = fromJSON(postForm('https://accounts.google.com/o/oauth2/token',
                                           refresh_token = refresh.token,
                                           client_id = client_id,
                                           client_secret = client_secret,
                                           grant_type = "refresh_token",
                                           style = "POST" ))
    
    return(refresh.token.list$access_token)
  }
  
  RemoveToken <- function(){
    # In case if the user wants to query a new profile, then the Authorization flow 
    # has to repeated. This requires deleting the stored Access and Refresh Tokens
    # from the system file
    # Args :
    #   None
    # Returns : 
    #   Deletes the Access Token file from the system
    
    if(file.exists(file.path(system.file(package = "RGoogleAnalytics"),
                             "accesstoken.rda"))) {
      unlink(file.path(system.file(package = "RGoogleAnalytics"),
                       "accesstoken.rda"),
             recursive = FALSE)
      cat("The Access token has been deleted from your system\n")    
    } else {
      stop(cat("The Access token file could not be found on your system\n"))
    }
    
  }
  
  RemoveAppCredentials <- function() {
    # In case if the user creates a new project in the Google API Developer Console, then
    # a fresh set of OAuth2.0 credentials (Client ID and Client Secret) are provided
    # This requires deletion of old stored credentials
    # Args : 
    #   None
    # Returns : 
    #   Deletes the app_credentials.rda file from the user's system
    
    if(file.exists(file.path(system.file(package = "RGoogleAnalytics"),
                             "app_credentials.rda"))) {
      unlink(file.path(system.file(package = "RGoogleAnalytics"),
                       "app_credentials.rda"),
             recursive = FALSE)
      cat("The Application Credentials have been deleted from your system\n")  
    } else {
      stop(cat("The Application Credentials file could not be found on your system\n"))
    }
    
  }
  
  
  ValidateToken <- function() {
    # This function checks whether the Access Token stored in the local file is 
    # expired. If yes, it generates a new Access Token and updates the local file.
    # If no, then it returns the stored Access Token
    # Args: 
    #    None 
    #  Returns: 
    #    access.token
    
    load(file.path(system.file(package = "RGoogleAnalytics"),
                   "accesstoken.rda"))
    
    api.response.json <- getURL(paste("https://www.googleapis.com/oauth2/v1/",
                                      "tokeninfo?access_token=",
                                      accesstoken.list$access_token,
                                      sep = "",
                                      collapse = ","))
    api.response.list <- fromJSON(api.response.json, method = 'C')  
    check.token.param <- regexpr("error", api.response.json)
    
    if (check.token.param[1] != -1) {
      #If token has expired Generate a New Access token
      cat("Access Token had expired. Regenerating access token\n") 
      access.token <- GenerateAccessToken()
      #Return the Newly generated access token
      return(access.token)
    } else {
      #Return the old access token
      return(accesstoken.list$access_token)
    }   
  }
  
  SetDataFrame <- function(GA.list.param.columnHeaders, dataframe.param) {
    # To prepare the dataframe by applying the column names and column datatypes 
    # to the provided data frame.
    #  Args:
    #    GA.list.param.columnHeaders: list includes GA reponse 
    #                                 data column name, column datatype.
    #    dataframe.param: The reponse data(dimensions and metrics data rows)
    #                     packed in dataframe without the column names and 
    #                     column types.
    # 
    #  Returns:
    #    dataframe.param : The dataframe attached with the column  names and 
    #    column datatype as per type the Dimnesions and metrics
    
    column.param <- t(sapply(GA.list.param.columnHeaders, 
                             '[',
                             1 : max(sapply(GA.list.param.columnHeaders,
                                            length))))
    col.name <- gsub('ga:', '', as.character(column.param[, 1]))
    col.datatype <- as.character(column.param[, 3])
    colnames(dataframe.param) <- col.name
    
    dataframe.param <- as.data.frame(dataframe.param)
    dataframe.param <- SetColDataType(col.datatype, col.name, dataframe.param)
    
    return(dataframe.param)
  }
  
  SetColDataType <- function(col.datatype, col.name, dataframe.param) {
    # This will set the appropriate data type to the each column of the 
    # provided dataframe.
    # Args: 
    #   col.datatype: The vector of the datatype of all the dimensions and 
    #                 metrics from the parsed list data.
    #   col.name:  The vector of the name of the all dimensions and metrics 
    #              of the retrived data and it will be attached to the 
    #              dataframe.param.
    # Returns:
    #   dataframe.param: The dataframe will be set with its column names with
    #   the appropriate class type.
    for(i in 1:length(col.datatype)) {
      if (col.datatype[i]=="STRING") {
        dataframe.param[, i] <- as.character(dataframe.param[, i]) 
      } else {
        dataframe.param[, i] <- as.numeric(as.character(dataframe.param[, i])) 
      }
    }
    return(dataframe.param)
  }
  
  GetProfilesFromJSON <- function(api.response.json) {
    # This function will do the parsing operation on the JSON reponse 
    # returned from the Google Management API and return the
    # dataframe stored with the profile id and prfile name
    # Args:
    #   api.reponse.json: The Json response from GetProfileData function 
    #                     which will request to the Google Management API.
    # Returns:
    #   Profileres.list: The list stored with totalResults as value of the 
    #                    total available data rows and profiles as the R 
    #                    dataframe object with two columns as column id and 
    #                    column name.        
    GA.profiles <- ParseApiErrorMessage(api.response.json)
    TotalProfiles <- GA.profiles$totalResults
    if (!is.null(GA.profiles$code)) {
      stop(paste("code: ",
                 GA.profiles$code,
                 "Reason: ",
                 GA.profiles$message))
    }
    
    GA.profiles.param <- t(sapply(GA.profiles$items,
                                  '[',
                                  1 : max(sapply(GA.profiles$items, length)))) 
    profiles.id <- as.character(GA.profiles.param[, 1])
    profiles.name <- as.character(GA.profiles.param[, 7])
    if (length(profiles.id)==0) {
      stop("Please check the access token. It may be invalid or expired")
    } else {
      profiles <- data.frame(id=profiles.id,
                             name=profiles.name,
                             stringsAsFactors = FALSE)
      profileres.list <- list(totalResults = TotalProfiles,
                              profiles = profiles)
      return(profileres.list)     
    }
  }
  
  GetAcctDataFeedJSON <- function(query.uri) {
    # This function will make a request to the Google Management API with
    # the query prepared by the QueryBuilder() for retriving the GA Account
    # data.
    # Args :
    #   query.uri: The data feed query string generated by the Query builder 
    #              Class.
    # Returns :
    #   GA.Data: The response as account data feed in the JSON format.
    
    #Validate the token before sending a request to the Management API
    access_token <- ValidateToken()
    
    GA.Data <- getURL(query.uri)
    return(GA.Data)
  }
  
  GetProfileData <- function() {
    # This function will retrive the available profiles from your 
    # Google anlaytics account by the Google Management API with the help of 
    # the access token. 
    # Args: 
    #   access_token: To authorize the user account.
    # Returns:
    #   profiles: R dataframe with profile id and profile name.
    
    #Access Token is loaded from system memory and not from external environment
    load(file.path(system.file(package = "RGoogleAnalytics"),
                   "accesstoken.rda"))
    
    query.uri <- paste('https://www.googleapis.com/analytics/v3/',
                       'management/accounts/~all/webproperties/~all/',
                       'profiles?access_token=',
                       accesstoken.list$access_token,
                       sep="", 
                       collapse = ",")
    if (!is.character(query.uri)) {
      stop("The query.uri parameter must be a character string")
    }
    
    # This api.reponse should be in json format
    api.response.json <- GetAcctDataFeedJSON(query.uri)
    profiles.param <- GetProfilesFromJSON(api.response.json)
    return(profiles.param$profiles)
  }
  
  ParseDataFeedJSON <- function(GA.Data) {
    # This function will parse the json response and checks if the reponse 
    # is contains an error, if found it will promt user with the related 
    # error message.
    # Args:
    #   GA.Data: The json reponse returned by the Google analytics Data 
    #            feed API. 
    # Returns:
    #    GA.list.param: GA.list.param list object obtained from this json 
    #                   argument GA.Data.
    GA.list.param <- ParseApiErrorMessage(GA.Data)
    if (!is.null(GA.list.param$code)) {
      stop(paste("code :",
                 GA.list.param$code,
                 "Reason :",
                 GA.list.param$message))
    }
    return(GA.list.param)
  }
  
  GetDataFeed <- function(query.uri) {
    # This will request with the prepared Query to the Google Analytics 
    # Data feed API and returns the data in dataframe R object.
    # Args: 
    #   query.uri: The URI prepared by the QueryBuilder class.
    # Returns:
    #   GA.DF: The dataframe stored with the dimensions and metrics 
    GA.Data <- getURL(paste(query.uri, sep = "", collapse = ","))  
    GA.list <- ParseDataFeedJSON(GA.Data)
    if (is.null(GA.list$rows)) {
      cat("Your query matched 0 results. Please verify your query.")
      break
    } else {
      return (GA.list)
    }
  }
  
  GetReportData <- function(query.builder, 
                            start.index = 1,
                            max.rows = NULL,
                            split_query_daywise=FALSE,
                            paginate_query=FALSE) { 
    # This function will retrieve the data by firing the query to the Core Reporting API. It also displays 
    # status messages after the completion of the query. The user also has the option split the query into 
    # daywise partitions and paginate the query responses in order to decrease the effect the sampling
    # Args : 
    #   query.builder : Name of the object corresponding to the QueryBuilder class 
    #   split_query_daywise : Splits the query by date range into sub queries of 
    #   single days. Default value of this argument is FALSE 
    #   paginate_query : Pages through chunks of results by requesting maximum 
    #   number of allowed rows at a time. Default Value of this argument is FALSE
    # Returns :
    #   api.response: The respose is in the dataframe format as the output 
    #                   data returned from the Google Analytics Data feed API.
    
    # query.builder$validate()
    
    # Ensure the starting index is set per the user request
    # We can only return 10,000 rows in a single query
    kMaxDefaultRows <- 10000
    max.rows <- query.builder$max.results()
    
    # If the user does not require pagination and query splitting 
    # fire the query and display the status messages
    if (split_query_daywise != T && paginate_query != T) {
      ga.list <- GetDataFeed(query.builder$to.uri())
      
      total.results <-  ga.list$totalResults
      items.per.page <- ga.list$itemsPerPage
      contains.sampled.data <- ga.list$containsSampledData
      response.size <- length(ga.list$rows)
      
      if (total.results < kMaxDefaultRows) {
        max.rows <- kMaxDefaultRows
      }
      
      # Convert the list object to a dataframe
      if (length(query.builder$dimensions()) == 0) {
        totalrows <- 1
        dataframe.param <- ga.list$rows[[1]]
        dim(dataframe.param) <- c(1, length(dataframe.param))
      } else {
        totalrows <- nrow(do.call(rbind, as.list(ga.list$rows)))
        dataframe.param <- rbind(dataframe.param, 
                                 do.call(rbind, as.list(ga.list$rows)))
      }
      
      final_df <- SetDataFrame(ga.list$columnHeaders, dataframe.param)
      
      # Print the status messages if query is not in batch mode
      if (length(ga.list$rows) < total.results) {
        cat("Status of Query:\n")
        cat("The API returned",response.size,"results out of",total.results,"results\n")
        cat("In order to get all results, set paginate_query = T in the GetReportData function.\n")
        if (max.rows < kMaxDefaultRows) {
          cat("Set max.rows = 10000 for efficient query utilization while Paginating\n")
        }
      } else {
        cat("Status of Query:\n")
        cat("The API returned",response.size,"results")
      }
      
      # Calculate the Percentage of Visits based on which the query was sampled
      # Reference : https://developers.google.com/analytics/devguides/reporting/core/v3/reference#sampling
      if (contains.sampled.data == T) {
        visits.for.sampled.query <- round(100 * (as.integer(ga.list$sampleSize)/
                                                   as.integer(ga.list$sampleSpace)),2)
        cat("The query response contains sampled data. It is based on ",visits.for.sampled.query,"% of your visits.\n")
        cat("You can split the query day-wise in order to reduce the effect of sampling.\n")
        cat("Set split_query_daywise = T in the GetReportData function\n")
        cat("Note that split_query_daywise = T will automatically invoke Pagination in each sub-query\n")
      }
    } else if (split_query_daywise == T) {
      
      GA.DF <- SplitQueryDaywise(query.builder)
      final_df <- SetDataFrame(GA.DF$header,GA.DF$data)
      cat("The API returned",nrow(final_df),"results\n")
      
    } else if (paginate_query == T) {
      
      #Validate the token and regenerate it if expired
      access_token <- ValidateToken()
      
      #Update the access token in the query object
      query.builder$SetAccessToken(access_token)
      
      #Hit One Query
      ga.list <- GetDataFeed(query.builder$to.uri())
      #Convert ga.list into a dataframe
      ga.list.df <- data.frame()
      ga.list.df <- rbind(ga.list.df,do.call(rbind,as.list(ga.list$rows)))
      
      #Check if pagination is required
      
      if (length(ga.list$rows) < ga.list$totalResults) {
        num_of_pages <- ceiling(ga.list$totalResults/length(ga.list$rows))
        
        #Clamp Number of Pages to 100 in order to enforce upper limit for pagination as 1M rows
        if (num_of_pages > 100) {
          num_of_pages <- kMaxPages
        }
        
        #Call Pagination Function
        paged.query.list <- PaginateQuery(query.builder,num_of_pages)
        
        #Collate Results and convert to Dataframe
        inter_df <- rbind(ga.list.df,paged.query.list$data)
        final_df <- SetDataFrame(paged.query.list$headers,inter_df)
        
        cat("The API returned",nrow(final_df),"results\n")
      } else {
        stop("Pagination is not required in the query.Set Paginate_Query = F and re-run the query\n")
      }
    }
    return(final_df)
  }
  
  SplitQueryDaywise <- function(query.builder) {
    # This function breaks up the time range (as specified by Start Date and End Date) into single days
    # and hits a query for each day. The responses for each queries are collated into a single dataframe and
    # returned. This procedure helps decrease the effect of sampling.
    # Reference: https://developers.google.com/analytics/devguides/reporting/core/v2/gdataReferenceDataFeed#largeDataResults
    # Args :  
    #  query.builder : Name of the object corresponding to the QueryBuilder class
    # Returns : 
    #  list containing the Column Headers and the Collated dataframe that represents the query response 
    # Note : require(lubridate)   
    
    #Validate the token and regenerate it if expired
    access_token <- ValidateToken()
    
    #Update the access token in the query object
    query.builder$SetAccessToken(access_token)
    
    #Updated to use Get Methods
    start_date <- ymd(query.builder$GetStartDate())
    end_date   <- ymd(query.builder$GetEndDate())
    
    date_diff <- as.numeric(difftime(end_date,start_date,units='days'))
    
    #Create an empty dataframe in order to store the results
    master_df <- data.frame()
    
    for (i in (0:date_diff)) {
      #Update the start and end dates in the query
      date <- format(as.POSIXct(start_date) + days(i), '%Y-%m-%d')
      cat("Run",i,"of",date_diff,"Getting data for",date,"\n")
      query.builder$SetStartDate(date)
      query.builder$SetEndDate(date)
      
      #Hit the first query corresponding the particular date
      first_query_df <- data.frame()
      first_query <- GetDataFeed(query$to.uri())
      first_query_df <- rbind(first_query_df, do.call(rbind, as.list(first_query$rows)))
      
      #Check if pagination is required in the query
      if (length(first_query$rows) < first_query$totalResults) {
        num_pages <- ceiling((first_query$totalResults)/length(first_query$rows))
        if (num_pages > 100) {
          num_pages <- kMaxPages
        }
        inter_df <- PaginateQuery(query.builder,num_pages)
        inter_df <- rbind(first_query_df,inter_df$data)
        master_df <- rbind(master_df,inter_df)
      } else {
        #No Pagination is required. Just append the rows to the dataframe
        master_df <- rbind(first_query_df,master_df)
      }
    }
    
    master_df <- rbind(first_query_df,master_df)
    
    return(list(header=first_query$columnHeaders,data=master_df))
  }
  
  PaginateQuery <- function(query.builder,pages) {
    # In case if a single query returns more than 10k rows,the Core Reporting API returns a subset of
    # the rows at a time. This function loops across all such subsets (pages) in order to retrieve data corresponding
    # to the entire query. The maximum number of rows corresponding to a single query that can be retrieved via Pagination
    # is 1 M. 
    # Reference: https://developers.google.com/analytics/devguides/reporting/core/v2/gdataReferenceDataFeed#largeDataResults
    # Args:
    #  query.builder : Name of the object corresponding to the query builder class
    #  pages : Integer representing the number of pages across which the query has to be paginated
    # Returns: 
    #  list containing Column Headers and the data collated across all the pages of the query
    
    #Validate the token and regenerate it if expired
    access_token <- ValidateToken()
    
    #Update the access token in the query object
    query.builder$SetAccessToken(access_token)
    
    #Create an empty dataframe in order to store the data
    df_inner <- data.frame()
    
    for (i in (2:pages-1)) {
      dataframe.param <- data.frame()
      start.index <- (i * kMaxDefaultRows) + 1
      cat("Getting data starting at row",start.index,"\n")
      query.builder$SetStartIndex(start.index)
      ga.list <- GetDataFeed(query.builder$to.uri())
      dataframe.param <- rbind(dataframe.param,
                               do.call(rbind, as.list(ga.list$rows)))
      df_inner <- rbind(df_inner,dataframe.param)
      col_headers <- ga.list$columnHeaders
      rm(ga.list)
    }
    return(list(headers=col_headers,data=df_inner))
  }
  
  
  ParseApiErrorMessage <- function(api.response.json) {
    # To check whether the returned JSON response is error or not. 
    # If it is error then it will  
    # Args :  
    #   api.response.json: The json data as reposnse returned by the 
    #   Google Data feed API or Google Management API
    # Returns :
    #   If there is error in JSON response then this function will return the 
    #   related error code and message for that error.
    api.response.list <- fromJSON(api.response.json, method = 'C')  
    check.param <- regexpr("error", api.response.list)
    if (check.param[1] != -1) {
      return(list(code = api.response.list$error$code,
                  message = api.response.list$error$message))
    } else {
      code <- NULL
      return(api.response.list)
    }   
  }
  ##############################################################################
  
  return(list(GetProfileData       = GetProfileData,
              GetReportData        = GetReportData,
              GetAppCredentials    = GetAppCredentials,
              GenerateAccessToken  = GenerateAccessToken,
              RefreshToAccessToken = RefreshToAccessToken,
              RemoveToken          = RemoveToken,
              ValidateToken        = ValidateToken, 
              RemoveAppCredentials = RemoveAppCredentials,
              kMaxDefaultRows      = kMaxDefaultRows)) 
}
