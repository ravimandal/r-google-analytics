Configuration <- function(){
  # Configuration class specially designed for retrieving the Google Analytics 
  # Configuration entities stored in the hierarchy. This class calls the 
  # Management API v3 to retrieve all these entities like Accouts, WebProperty, 
  # WebProfiles, Goals, Customsource and Segments (which is not in hierarchy).   
  #
  # To get more detailed information about the order of these entities, visit to
  # https://developers.google.com/analytics/devguides/config/mgmt/v3/#concepts
  # https://developers.google.com/analytics/devguides/config/mgmt/v3/
    
  # Set the curl options    
  options(RCurlOptions = list(capath = system.file("CurlSSL",
                                                   "cacert.pem", 
                                                   package = "RCurl"),
                              ssl.verifypeer = FALSE))

  GetAccounts <- function() {
    # This function will retrieve all of the accounts from Google Analytics.
	# Args: No Arguments
	#
	# Returns: 
	#   accounts: The response will be in the data frame format with two columns 
	#             one is id and name of accounts.	
    access_token <- ValidateToken(access_token)
    query.uri <- paste("https://www.googleapis.com/analytics/v3/management/accounts?access_token=",
                       access_token,
                       sep="",
                       collapse=",")
    GA.Accounts.df  <- RetrieveConfigurationData(query.uri)
    return(DataFramepacker(GA.Accounts.df,"accounts"))
  }

  GetWebProperty <- function(account.param=NA) {
    # This function will retrieve either all of the web properties 
	# or specific with respected to account parameter passed with as parameter.
    # Args:
	#   account.param: The specific account id retrieved from GetAccounts()
    # Returns:	
	#   web prpoperty: The response will be in data frame format, which contains 
    #                  the list of the available web properties and their metadata.	
    account <- ParameterSelector(account.param)
    access_token <- ValidateToken(access_token)
    query.uri <- paste("https://www.googleapis.com/analytics/v3/management/accounts/",
                       account,
                       "/webproperties?access_token=",
	    			   access_token,
				       sep="",
				       collapse=",")
    GA.WebProperty.df  <- RetrieveConfigurationData(query.uri)
    return(DataFramepacker(GA.WebProperty.df, "webproperties"))
  }

  GetWebProfile <- function(account.param=NA, webProperty.param=NA){
    # This fuction will retrieve either all of the profiles or specif based on the 
	# the input paramet passed with in the function.
	# Args:
    #   account.param: The specific account id retrieved from GetAccounts()
    #   webProperty.param: The specific webProperty id retrieved from GetWebProperty()	
	# Returns:
    #   web profiles: The reponse will be in the data frmae format. Which contains 
	#                 the list of web profiles and their metadata.
	account <- ParameterSelector(account.param)
    webProperty <- ParameterSelector(webProperty.param)
    access_token <- ValidateToken(access_token)
    query.uri <- paste("https://www.googleapis.com/analytics/v3/management/accounts/",
                       account, "/webproperties/",
                       webProperty, "/profiles?access_token=",
                       access_token, 
                       sep="",
                       collapse=",")
    GA.WebProfile.df  <- RetrieveConfigurationData(query.uri)
    return(DataFramepacker(GA.WebProfile.df, "profiles"))
  }

  GetGoals <- function(account.param=NA, webProperty.param=NA, webProfile.param=NA){
    # This function will retrieve either all of the goals or specific based on the
	# input parameteres passed with in the function.
	# Args:
	#  account.param: The account id retrieve from GetAccounts()
	#  webProperty.param:  The webproperty id retrieved from GetWebProperty()
	#  webProfile.param: The profile id retrieved from GetWebProfile()
	# Returns:
	#  goals: The response will be in the daat frame format. Which contains the list
	#         of goals and their metadata.
	account <- ParameterSelector(account.param)
    webProperty <- ParameterSelector(webProperty.param)
    webProfile <- ParameterSelector(webProfile.param)
    access_token <- ValidateToken(access_token)
    query.uri <- paste("https://www.googleapis.com/analytics/v3/management/accounts/",
                       account,"/webproperties/",
					   webProperty,"/profiles/",
					   webProfile,"/goals?access_token=",
                       access_token, 
                       sep="",
                       collapse=",")  
    GA.Goals.df  <- RetrieveConfigurationData(query.uri)
    return(DataFramepacker(GA.Goals.df,"goals"))
  }

  GetSegments <- function(){
    # This function will retrieve the user's advance segments or custom segments 
    # created under user's Google Analytics account 
    # Args: No arguments
    # Returns:
    #  segments: The response will be in the data frame format. Which includes the 
    #            list of segments.
    access_token <- ValidateToken(access_token)
    query.uri <- paste("https://www.googleapis.com/analytics/v3/management/segments?access_token=",
                       access_token, 
                       sep="",
                       collapse=",")
    GA.Segments.df  <- RetrieveConfigurationData(query.uri)
    return(DataFramepacker(GA.Segments.df,"segments")) 
  }

  GetCustomSource <- function(account.param=NA, webProperty.param=NA){
    # This function wil retrieve the custom data source created under the Google 
	# Analytics accounts.
	# Args:
	#   account.param: The account id retrieved from GetAccounts()
    #  	webProperty.param: The web roperty id retrieved from GetWebProperty()
	# Returns:
	#   custom data source: The response will be in the data frame format. Which 
	#                       includes the information about custom data source. 
    account <- ParameterSelector(account.param)
    webProperty <- ParameterSelector(webProperty.param)
    access_token <- ValidateToken(access_token)
    query.uri <- paste("https://www.googleapis.com/analytics/v3/management/accounts/",
                       account,"/webproperties/",
					   webProperty,"/customDataSources?access_token=",
                       access_token,
                       sep="",
                       collapse=",")
    GA.CustomSource.df  <- RetrieveConfigurationData(query.uri)
    return(DataFramepacker(GA.CustomSource.df, "customdatasources"))
  }

  RetrieveConfigurationData <- function(query.uri){
    # This function is defined for retrieving the Google Analytics Configuration 
	# data by calling Google Management API v3.
	# Args:
	#   query.uri: It is the prepared query string with query parameters to be requested to 
	#              Management API v3.
	# Returns:
	#   GA.Data.df: The JSON response from the Management API will be translated in 
	#               to the dataframe format with GA.Data.df object.  
    if (!is.character(query.uri)) {
      stop("the query.uri parameter must be a character string")
    }
  
    # This api.reponse should be in json format
    api.response.json <- getURL(query.uri)
    GA.Data.list <- ParseApiErrorMessage(api.response.json)
    GA.Data <- t(sapply(GA.Data.list$items, 
                            '[',
							1:max(sapply(GA.Data.list$items,
						    length)))) 
    GA.Data.df <- as.data.frame(GA.Data,
                                stringsAsFactors = FALSE)
    return(GA.Data.df)   
  }

  DataFramepacker <- function(df.param,df.name){
    # This function is defined for subset the retrieving the data frame data of 
	# various configuration elements.
	# Args: 
	#   df.param: df.param is the extraceted dataset in the data frame format.
	#   df.name: This is the configuration identifier for the df.param dataset 
	# Returns:
	#   df: The response is in the format of dataframe which is having the only 
	#       important columns.	
    if (df.name == "accounts"){
      df <- data.frame(id=do.call(rbind, df.param$id),
	                   name=do.call(rbind, df.param$name),
					   stringsAsFactors=FALSE)
    return(df)
    }
    if (df.name == "webproperties"){
      df <- data.frame(id=do.call(rbind, df.param$id),
	                   accountId = do.call(rbind, df.param$accountId),
					   name=do.call(rbind, df.param$name),
					   websiteUrl = do.call(rbind, df.param$websiteUrl),
					   stringsAsFactors=FALSE)    
      return(df)
    }  
    if (df.name == "profiles"){
      df <- data.frame(id=do.call(rbind, df.param$id),
	                   name=do.call(rbind, df.param$name),
					   websiteUrl = do.call(rbind, df.param$websiteUrl), 
					   accountId = do.call(rbind, df.param$accountId),
					   webPropertyId = do.call(rbind, df.param$webPropertyId),
					   stringsAsFactors=FALSE)    
      return(df) 
    }
   if (df.name == "goals"){
     df <- data.frame(id=do.call(rbind, df.param$id),
	                  name = do.call(rbind, df.param$name),
					  active= do.call(rbind, df.param$active), 
					  type= do.call(rbind, df.param$type),
					  profileId=do.call(rbind, df.param$profileId), 
					  accountId = do.call(rbind, df.param$accountId),
					  webPropertyId = do.call(rbind, df.param$webPropertyId),
					  stringsAsFactors=FALSE)    
     return(df)
    }
    if (df.name == "customdatasources"){
      df <- data.frame(accountId=do.call(rbind, df.param$accountId),
	                   webPropertyId=do.call(rbind, df.param$webPropertyId),
 	                   name=do.call(rbind, df.param$name), 
					   description=do.call(rbind, df.param$description), 
					   type=do.call(rbind, df.param$type),
					   profilesLinked=do.call(rbind, df.param$profilesLinked),
					   stringsAsFactors=FALSE)  
      row.names(df) <- ""
	  return(df)
    } 
    if (df.name == "segments"){
      df <- data.frame(id=do.call(rbind, df.param$id),
	                   segmentId=do.call(rbind, df.param$segmentId),
	   				   name =do.call(rbind, df.param$name),
					   stringsAsFactors=FALSE)
      return(df)
    }
  }
  
  ParameterSelector <- function(input.param = NA){
    # This function will manage the input parameters used with in GetAccounts(),
    # GetWebProperty(), GetWebProfile(), GetWebProfile() and GetGoals for selecting 
	# all of the data value or specific data value for that configuration.
	# Args:
	#   input.param: This is the input parameter value for one of the above methods.
	# Returns:
	#   param: The response will be in string vector format. If the input parameter 
    #          is not defined with its value then it will be assigned as "~all" to 
    #          retrieve all of the configuration values other wise the adta will 
    #          retrieved based on the defined value of that configuration parameter.	
    if (is.null(input.param)) {
      input.param <- NULL
      return(invisible())
    }
    if (is.na(input.param)) {
      input.param <- "~all"
      return(input.param)    
    }
    param <- input.param
    return(param)
  }
  
  ValidateToken <- function(access.token) {
  # This function will check whether the provided access_token is valid or 
  # expired. If it is a valid access token then it will return itself,
  # otherwise stop the execution.
  #  Args: 
  #    access.token: the token generated by Oauth 2.0 API to 
  #                  authorize the user account for Google Analytics 
  #                  data extraction.
  #  Returns: 
  #       access.token:
    api.response.json <- getURL(paste("https://www.googleapis.com/oauth2/v1/",
                                      "tokeninfo?access_token=",
                                      access.token,
                                      sep = "",
                                      collapse = ","))
    api.response.list <- fromJSON(api.response.json, method = 'C')  
    check.token.param <- regexpr("error", api.response.json)
    if (check.token.param[1] != -1) {
      stop(paste("Invalid/Expired access_token, regenerate",
               "token by 'access_token <- query$authorize()'"))
    } else {
      return(access.token)
    }		
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
################################################################################
  return(list(GetAccounts=GetAccounts,
            GetWebProperty=GetWebProperty,
			GetWebProfile=GetWebProfile,
			GetGoals=GetGoals,
			GetSegments=GetSegments,
			GetCustomSource=GetCustomSource,
			DataFramepacker=DataFramepacker,
			ParameterSelector=ParameterSelector))
}