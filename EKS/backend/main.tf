terraform {
  required_version = ">= 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "backend" {
    source = "./modules/s3"
    bucket_name = var.bucket_name
    dynamodb_table_name = var.dynamodb_table_name
    region = var.region
}
