# For attaching GaOAuth2.R to use its functions.
source("D:/Office/vignesh/Projects/RGA/New_auth_script/GaOAuth2_.R")

# To Generate the accesstoken based on user's application credentials.
access_token <- GenerateAccessToken()


############ Code to extract the GA data will be placed here ##################

# To Remove the stored access token OR need to access the GA data of 
# different profile, then first we need to have remove old GA access token 
# and reauthorize the account.
RemoveToken()


