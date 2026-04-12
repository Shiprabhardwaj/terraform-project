variable "region" {
    description = "AWS region for the EKS cluster"
    type        = string
    default = "us-east-2"
}

variable "bucket_name" {
    description = "Name of the S3 bucket for Terraform state"
    type        = string
    default = "statefile-eks-terraform-1356"
}

variable "dynamodb_table_name" {
    description = "Name of the DynamoDB table for Terraform state locking"
    type        = string
    default = "terraform-lock"
}
