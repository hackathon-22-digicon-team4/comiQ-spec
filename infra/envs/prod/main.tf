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

module "production_network" {
  source = "../../modules/network"
  project = var.project
  stage = var.stage
  cidr_block_vpc = "10.0.0.0/16"
  cidr_block_public_1a = "10.0.10.0/24"
  cidr_block_public_1c = "10.0.20.0/24"
  cidr_block_private_1a = "10.0.30.0/24"
  cidr_block_private_1c = "10.0.40.0/24"
  az_1a = "ap-northeast-1a"
  az_1c = "ap-northeast-1c"
}
