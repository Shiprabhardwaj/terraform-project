variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "region" {
    description = "AWS region for the VPC"
    type        = string
}

variable "public_subnet_cidr" {
    description = "CIDR block for the public subnet"
    type        = list(string)
}

variable "private_subnet_cidr" {
    description = "CIDR block for the private subnet"
    type        = list(string)
}

variable "availability_zones" {
    description = "List of availability zones for the subnets"
    type        = list(string)
}

variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}
