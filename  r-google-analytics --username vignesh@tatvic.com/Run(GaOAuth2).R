# For attaching GaOAuth2.R to use its functions.
source("GaOAuth2.R")

# To Generate the accesstoken based on user's application credentials.
access_token <- GenerateAccessToken()

############ Code to extract the GA data will be placed here ##################

# To Remove the stored access token OR need to access the GA data of 
# different profile, then first we need to have remove old GA access token 
# and reauthorize the account.
RemoveToken()


