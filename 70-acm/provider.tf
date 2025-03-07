terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.89.0"
    }
  }
  backend "s3" {
    bucket = "tf-expense-remote-state"
    key = "tf-acm-module"
    region = "us-east-1"
    dynamodb_table = "expense-infra-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}