variable "cluster_name" {
    description = "Name of the EKS cluster"
    type        = string
}
variable "region" {
    description = "AWS region for the EKS cluster"
    type        = string
}
variable "vpc_id" {
    description = "ID of the VPC where the EKS cluster will be deployed"
    type        = string
}
variable "subnet_ids" {
    description = "List of subnet IDs for the EKS cluster"
    type        = list(string)
}
variable "node_groups" {
    description = "EKS node group configuration"
    type        = map(object({
        instance_types = list(string)
        capacity_type  = string
        scaling_config = object({
        desired_capacity = number
        max_capacity = number
        min_capacity = number
        })
    }))
}