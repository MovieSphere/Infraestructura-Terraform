terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region  = var.region
  profile                 = "default"
  shared_config_files     = [pathexpand("~/.aws/config")]
  shared_credentials_files = [pathexpand("~/.aws/credentials")]
}
