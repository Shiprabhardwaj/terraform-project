output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "node_groups" {
  description = "EKS node groups"
  # This loops through the map and pulls the 'node_group_name' attribute from each
  value       = [for ng in aws_eks_node_group.node_group : ng.node_group_name]
}