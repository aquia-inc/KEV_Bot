<div style="text-align:center">![image](https://user-images.githubusercontent.com/116001028/211614648-d3fba293-d114-40f6-96a7-b2321e657f37.png)</div>

[![GitHub Super-Linter](https://github.com/aquia-inc/KEV_Bot/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)  

# Description  
KEV Bot (KB) periodically checks the [CISA Known Exploited Vulnerabilities catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) for new entries.  When KB detects a new entry to the catalog, KB tweets an announcement of the new entry.

## AWS Services Used  
Event Bridge  
DynamoDB  
Lambda  
SSM  
S3 (if using github actions)

# How to deploy with github actions  
## Prerequisites  
1. Twitter developer account with elevated access  
2. AWS Account and [Github OIDC configured](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
## Configure the following github secrets  
1. ROLE_TO_ASSUME  - From AWS account KEV Bot will be deployed
2. API_KEY  - Twitter API KEY  
3. API_KEY_SECRET  - Twitter API Key Secret  
4. ACCESS_TOKEN  - Twitter Access Token  
5. ACCESS_TOKEN_SECRET  - Twitter Token Secret  
## Modify provider.tf  
Configure provider.tf to point to a s3 bucket in your aws account  
## Push to main
Push requests approved to the main branch will trigger GitHub actions and deploy KEV bot to your AWS account.


# How to deploy without github actions  

## Prerequisites  
1. Twitter developer account with elevated access  
2. Twitter API kyes stored as environment variables TWITTER_API_KEY, TWITTER_API_KEY_SECRET, TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET  
3. Terraform installed and configured with an AWS account  
4. Python 3 installed  
5. pip installed and in path 
6. delete provider.tf from KEV Files

## Deploy Linux  
```bash
terraform apply -auto-approve -input=false -var="api_key=$TWITTER_API_KEY" -var="api_key_secret=$TWITTER_API_KEY_SECRET" -var="access_token=$TWITTER_ACCESS_TOKEN" -var="access_token_secret=$TWITTER_ACCESS_TOKEN_SECRET”
```  
## Deploy Windows cmd
```cmd
terraform apply -auto-approve -input=false -var="api_key=%TWITTER_API_KEY%" -var="api_key_secret=%TWITTER_API_KEY_SECRET%" -var="access_token=%TWITTER_ACCESS_TOKEN%" -var="access_token_secret=%TWITTER_ACCESS_TOKEN_SECRET%”
```


