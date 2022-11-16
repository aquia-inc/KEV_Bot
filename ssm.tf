
variable "api_key" {
  type = string
}

variable "api_key_secret" {
  type = string
}

variable "access_token" {
  type = string
}

variable "access_token_secret" {
  type = string
}

resource "aws_ssm_parameter" "twitter_api_key_iac" {
  name  = "twitter_api_key_iac"
  type  = "SecureString"
  value = var.api_key
}

resource "aws_ssm_parameter" "twitter_api_secret_iac" {
  name  = "twitter_api_secret_iac"
  type  = "SecureString"
  value = var.api_key_secret
}

resource "aws_ssm_parameter" "twitter_access_token_iac" {
  name  = "twitter_access_token_iac"
  type  = "SecureString"
  value = var.access_token
}

resource "aws_ssm_parameter" "twitter_access_secret_token_iac" {
  name  = "twitter_access_secret_token_iac"
  type  = "SecureString"
  value = var.access_token_secret
}

