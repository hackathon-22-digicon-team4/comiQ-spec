provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      service = "comiQ"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "comiq-tfstate"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
    profile = "comiq"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
  }
}
