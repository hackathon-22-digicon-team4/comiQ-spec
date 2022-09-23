terraform {
  backend "s3" {
    bucket  = "digicon-team4-tfstate"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
  }
  required_providers {
    aws = "~>4.0"
  }
}