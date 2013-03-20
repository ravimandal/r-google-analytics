# Loading the required library. 
require(RCurl)
require(rjson)

# For windows user to get the SSL certificate. 
options(RCurlOptions = list(capath = system.file("CurlSSL",
                                                 "cacert.pem", 
                                                 package = "RCurl"),
                            ssl.verifypeer = FALSE))

# Function to generate the access token for GA data extraction process. 
# Generated access token will be stored in to the directory where 
# the RGoogleAnalytics package located with RDA(.rda) file format.
GenerateAccessToken <- function(){
  # This condition will check whether the access token is already stored/generated or not.
  if (!file.exists(file.path(system.file(package = "RGoogleAnalytics"),
                             "accesstoken.rda"))) {
  # If access token is not stored, then this block will be executed.  
  # Supply your credentials for an installed app.
    client_id <- "Set your cliet id of Google application" 
    client_secret <- "Set your cliet secret of Google application"  
    redirecturi <- "urn:ietf:wg:oauth:2.0:oob"
	  
  # For building request query for retrieving access token.
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
	  
  # Load a prepared URL into a WWW browser.
    browseURL(url) 
    cat("The GA data extraction process required authorization code.",
        "To accept the auth code, you need to follow certain steps in your ",
        "browser. This code will help this R packge to generate the access",
        "token. Make sure you have already supplied credentials for installed app.",
        "\n\nSteps to be followed : \n1. Authorize your",
        "Google Analytics account by providing email and password. \n ",
        "\n2. Copy the generated code.")
    code <- readline(as.character(cat("\n\nPaste the authorization code here",
                                      ":=>")))
  # For retriving the access token.
    accesstoken <- fromJSON(postForm('https://accounts.google.com/o/oauth2/token',
                                      code = code,
                                      client_id = client_id, 
                                      client_secret = client_secret,
                                      redirect_uri = redirecturi,
                                      grant_type = "authorization_code",
                                      style = "POST"))

  # For saving the generated access token (as List data type with 
  # values - access_token, token_type, expires_in and refresh_token)
  # at file system where RGoogleAnalytics package located.
    access_token <- accesstoken$access_token 
    save(accesstoken, 
         client_id,
         client_secret,
         file = file.path(system.file(package = "RGoogleAnalytics"),
                          "accesstoken.rda"))
    print("access token has been saved")
    return (access_token)
  } else {
    attach(file.path(system.file(package = "RGoogleAnalytics"),
                     "accesstoken.rda"),
           warn.conflicts = F)
  # Based on the refresh token regenrate the access token
    accesstoken <- RefreshToAccesstoken(accesstoken)
  # This will store access token to access_token which will be used by our R package.
    access_token <- accesstoken$access_token
    print("access token has been regenerated")
    return (access_token)
  }
}

# Function to remove the stored access token. This will be helpful when need to 
# extract the Google Analytics data from another Google Account than previous.
RemoveToken <- function(){
  unlink(file.path(system.file(package = "RGoogleAnalytics"),
                   "accesstoken.rda"),
         recursive = FALSE)
  print("access token have been deleted")
}

# Function to generate the fresh access token from refresh token.
RefreshToAccesstoken <- function(accesstoken){
  rt = fromJSON(postForm('https://accounts.google.com/o/oauth2/token',
                          refresh_token = accesstoken$refresh_token,
                          client_id = client_id,
                          client_secret = client_secret,
                          grant_type = "refresh_token",
                          style = "POST" ))
  accesstoken$access_token = rt$access_token
  accesstoken$expires_in = rt$expires_in
  return(accesstoken)
}