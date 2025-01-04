terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    bitbucket = {
      source  = "zahiar/bitbucket"
      version = "1.6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "me-central-1"
  profile = "BA"
}

provider "aws" {
  region = "us-east-1"
  alias = "us_east"
}

data "aws_region" "current" {}
