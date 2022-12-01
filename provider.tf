provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket  = "961654424229-tf-state"
    key     = "kev-bot"
    region  = "us-east-1"
  }
}