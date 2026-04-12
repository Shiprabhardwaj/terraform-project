terraform {
    required_version = ">= 0.12"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
    backend "s3" {
        bucket = "statefile-eks-terraform-1356"
        key = "terraform.tfstate"
        region = "us-east-2"
        dynamodb_table = "terraform-lock"
        encrypt = true
    }
}


provider "aws" {
  region = var.region
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    region = var.region
    cluster_name = var.cluster_name
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    availability_zones = var.availability_zones
}

module "eks" {
    source = "./modules/eks"
    cluster_name = var.cluster_name
    region = var.region
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnet_ids
    node_groups = var.node_groups
}
