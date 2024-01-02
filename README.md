
![image](https://user-images.githubusercontent.com/116001028/211614648-d3fba293-d114-40f6-96a7-b2321e657f37.png)
 

[![GitHub Super-Linter](https://github.com/aquia-inc/KEV_Bot/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter) 
[![CodeQL](https://github.com/aquia-inc/KEV_Bot/workflows/CodeQL/badge.svg)](https://github.com/aquia-inc/KEV_Bot/actions?query=workflow%3ACodeQL "Code quality workflow status")

# Description
KEV Bot periodically checks the [CISA Known Exploited Vulnerabilities catalog](https://www.cisa.gov/known-exploited-vulnerabilities-catalog) for new entries.  When KEV Bot detects a new entry to the catalog, KEV Bot slacks an announcement of the new entry.

## AWS Services Used
Event Bridge  
DynamoDB  
Lambda  
SSM  
S3 (if using github actions)

# How to deploy with github actions
## Prerequisites
1. AWS Account and [Github OIDC configured](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
2. Fork this repo
## Configure the following github secrets on your fork
1. ROLE_TO_ASSUME  - From AWS account KEV Bot will be deployed
2. SLACK_WEBHOOK_URL  - Slack incoming webhook URL to send notifications
## Modify provider.tf
Configure provider.tf to point to a s3 bucket in your aws account  
## Push to main
Push requests approved to the main branch will trigger GitHub actions and deploy KEV bot to your AWS account.


# How to deploy without github actions

## Prerequisites  
1. Terraform installed and configured with an AWS account
2. Python 3 installed
3. pip installed and in path
4. delete provider.tf from KEV Files
5. Slack app configured with an incoming webhook

## Deploy Linux
```bash
terraform init
terraform plan -input=false -var="slack_webhook_url=$SLACK_WEBHOOK_URL"
terraform apply -input=false -var="slack_webhook_url=$SLACK_WEBHOOK_URL"
```
## Deploy Windows cmd
```cmd
terraform init
terraform plan -input=false -var="slack_webhook_url=%SLACK_WEBHOOK_URL%"
terraform apply -input=false -var="slack_webhook_url=%SLACK_WEBHOOK_URL%"
```


