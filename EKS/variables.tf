variable "region" {
    description = "AWS region for the EKS cluster"
    type        = string
    default = "us-east-2"
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
    default     = "test-eks-cluster"
}

variable "node_group_name" {
    description = "Name of the EKS node group"
    type        = string
    default     = "test-node-group"
}

variable "availability_zones" {
    description = "List of availability zones for the subnets"
    type        = list(string)
    default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
variable "bucket_name" {
    description = "Name of the S3 bucket for Terraform state"
    type        = string
    default     = "statefile-eks-terraform-1356"
}

variable "dynamodb_table_name" {
    description = "Name of the DynamoDB table for Terraform state locking"
    type        = string
    default     = "terraform-lock"
}

variable "cidr_block" {
    description = "CIDR block for the VPC"
    type        = string
    default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "List of CIDR blocks for public subnets"
    type        = list(string)
    default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnet_cidr" {
    description = "List of CIDR blocks for private subnets"
    type        = list(string)
    default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "node_groups" {
  description = "EKS node group configuration"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    scaling_config = object({
      desired_capacity = number
      max_capacity     = number
      min_capacity     = number
    })
  }))
  default = {
    general = {
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      scaling_config = {
        desired_capacity = 2
        max_capacity     = 4
        min_capacity     = 1
      }
    }
  }
}
