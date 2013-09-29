Contents in this file are as below
A. Prerequisites
B. Scenario
C. File References
D. Link References


A. Prerequisites :
   To retrive the access token via Google installed App flow,
   there are some prerequisites as 
1. User have to register the Project under Google API console.
   - For configuring RGoogleAnalytics package via client id and client secret
2. Analytics API service must be enabled.
3. In Analytics account, there must be at least one Google Analytics profile registered.


B. Scenario : 
   For retrieving the access token from Google installed app credentials.
1. User calls GenerateAccessToken () function first time, he must be allowed the 
   Google consent to acquire the access token.
     
2. Generated accesstoken.rda stored in a location where RGoogleAnalytics package has been 
   located. (Will be same for both O.S. Linux as well as windows ) 
   
   Where accesstoken.rda contains following values 
    a. access_token 
	b. token_type     
    c. expires_in
	d. refresh_token

	And this access token will be valid until an hour, so after one hour user
 	need to regenerate the access token via calling GenerateAccessToken(). Also
	the stored accesstoken.rda file will be replaced with fresh access token and
    return it to R work space.	
	
3. When User needs to retrieve the GA data from another GA account then he needs to
   remove already generated access token via RemoveToken() of GaOAuth2.R file.
   After he need to generate new access token for another account via re-authorizing via 
   Google consent.
   
   
C. File References :
1. GaOAuth2.R
   This is the R file with three functions 
   GenerateAccessToken() - To generate the access token from App credentials.
   RemoveToken() - To remove already generated access token.
   RefreshToAccesstoken () - To generate the access token from a refresh token.
   
2. Run.R
   With sample codes to use the functions of GaOAuth2.R file.   
   
D. Link References :
https://developers.google.com/accounts/docs/OAuth2WebServer
https://github.com/greentheo/ROAuthSamples/blob/master/gaGetCredentials_sample.R