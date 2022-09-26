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
  source                = "../../modules/network"
  project               = var.project
  stage                 = var.stage
  cidr_block_vpc        = "10.0.0.0/16"
  cidr_block_public_1a  = "10.0.10.0/24"
  cidr_block_public_1c  = "10.0.20.0/24"
  cidr_block_private_1a = "10.0.30.0/24"
  cidr_block_private_1c = "10.0.40.0/24"
  az_1a                 = "ap-northeast-1a"
  az_1c                 = "ap-northeast-1c"
}

# DBインスタンスにアクセスする踏み台サーバー
# EC2
module "step_ec2" {
  source     = "../../modules/ec2"
  project    = var.project
  stage      = var.stage
  public_1a  = module.production_network.public_sub_1a
  public_1c  = module.production_network.public_sub_1c
  sg_ec2_alb = module.production_network.sg_for_ecs
  sg_ec2_ssh = module.production_network.sg_for_ssh
}

# ALB, DNS
module "production_routing" {
  source     = "../../modules/routing"
  project    = var.project
  stage      = var.stage
  vpc        = module.production_network.vpc
  public_1a  = module.production_network.public_sub_1a
  public_1c  = module.production_network.public_sub_1c
  sg_for_alb = module.production_network.sg_for_alb
}

# fronend
module "production_frontend" {
  source  = "../../modules/frontend"
  project = var.project
  stage   = var.stage
  zone_id = module.production_routing.zone_id
}

# for github actions cd
module "cd" {
  source = "../../modules/cd"
  s3_arn = module.production_frontend.s3_arn
}

# ECR
module "production_ecr" {
  source = "../../modules/ecr"
  name   = "comiq-server"
}

# secret manager for server env
module "production_secret_manager" {
  source = "../../modules/secret_manager"
  name   = "comiq-server-env"
}

# iam module
module "production_iam" {
  source             = "../../modules/iam"
  stage              = var.project
  project            = var.project
  env_secret_manager = module.production_secret_manager.env_secret_manager
}

# ECS
module "production_ecs" {
  source                  = "../../modules/ecs"
  project                 = var.project
  stage                   = var.stage
  public_1a               = module.production_network.public_sub_1a
  public_1c               = module.production_network.public_sub_1c
  ecs_task_execution_role = module.production_iam.ecs_task_execution_role
  sg_for_ecs              = module.production_network.sg_for_ecs
  tg                      = module.production_routing.tg
  container_port          = 50001
  region                  = "ap-northeast-1"
  env_secret_manager      = module.production_secret_manager.env_secret_manager
  ecr_repo_uri            = "738925651667.dkr.ecr.ap-northeast-1.amazonaws.com/comiq-server:latest"
}

# RDS
module "production_rds" {
  source         = "../../modules/db"
  private_sub_1a = module.production_network.private_sub_1a
  private_sub_1c = module.production_network.private_sub_1c
  sg_for_rds     = module.production_network.sg_for_rds
}