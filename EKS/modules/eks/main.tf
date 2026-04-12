resource "aws_eks_cluster" "eks" {
  name = "eks-cluster"
  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "node_group_role" {
    name = "eks-node-group-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sts:AssumeRole",
                    "sts:TagSession"
                ]
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}   

resource "aws_iam_role_policy_attachment" "node_policy" {
    for_each = toset([
        "AmazonEKSWorkerNodePolicy",
        "AmazonEKS_CNI_Policy",
        "AmazonEC2ContainerRegistryReadOnly"
    ])
    policy_arn = "arn:aws:iam::aws:policy/${each.value}"
    role       = aws_iam_role.node_group_role.name
}


resource "aws_eks_node_group" "node_group" {
  for_each = var.node_groups
  cluster_name    = aws_eks_cluster.eks.name
  #each key is the node group name and value is the object containing instance type, capacity type and scaling config
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.subnet_ids
  instance_types   = each.value.instance_types
  capacity_type    = each.value.capacity_type  

  scaling_config {
    desired_size = each.value.scaling_config.desired_capacity
    max_size     = each.value.scaling_config.max_capacity
    min_size     = each.value.scaling_config.min_capacity
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy
  ]
} 