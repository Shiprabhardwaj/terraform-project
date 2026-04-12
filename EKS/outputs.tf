output "cluster_name" {
    description = "Name of the EKS cluster"
    value       = module.eks.cluster_name
}

output "node_group" {
    description = "Name of the EKS node group"
    value       = module.eks.node_groups
}

output "vpc_id" {
    description = "ID of the VPC"
    value       = module.vpc.vpc_id
}

output "cluster_endpoint" {
    description = "Endpoint of the EKS cluster"
    value       = module.eks.cluster_endpoint
}

