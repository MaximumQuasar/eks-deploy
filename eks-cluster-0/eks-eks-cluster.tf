resource "aws_eks_cluster" "eks-slvr-cluster-0" {
  name                      = "eks-slvr-cluster-0"
  role_arn                  = aws_iam_role.eks-clusterrole-0.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks-sbn-private-02-cluster-0.id,aws_subnet.eks-sbn-private-01-cluster-0.id,aws_subnet.eks-sbn-public-02-cluster-0.id,aws_subnet.eks-sbn-public-01-cluster-0.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_nat_gateway.eks-private-ngw-02-cluster-0,
    aws_nat_gateway.eks-private-ngw-01-cluster-0,
    aws_route_table_association.eks-private-ascrt-01-cluster-0,
    aws_route_table_association.eks-private-ascrt-02-cluster-0,
    aws_route_table_association.eks-public-ascrt-01-cluster-0,
    aws_route_table_association.eks-public-ascrt-02-cluster-0,
    aws_route.eks-public-r-cluster-0,
    aws_route.eks-private-r-01-cluster-0,
    aws_route.eks-private-r-02-cluster-0,
    aws_iam_role_policy_attachment.eksclusterpolicy
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks-slvr-cluster-0.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-slvr-cluster-0.certificate_authority[0].data
}

resource "aws_eks_node_group" "eks-worker-node-cluster-0" {
  cluster_name    = aws_eks_cluster.eks-slvr-cluster-0.name
  node_group_name = "eks-worker-node-cluster-0"
  node_role_arn   = aws_iam_role.eks-wnode-iam-role-cluster-0.arn
  subnet_ids      = [aws_subnet.eks-sbn-private-02-cluster-0.id,aws_subnet.eks-sbn-private-01-cluster-0.id,aws_subnet.eks-sbn-public-02-cluster-0.id,aws_subnet.eks-sbn-public-01-cluster-0.id]
  scaling_config {
    desired_size = 4
    max_size     = 6
    min_size     = 4
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.eks-slvr-cluster-0,
    aws_nat_gateway.eks-private-ngw-02-cluster-0,
    aws_nat_gateway.eks-private-ngw-01-cluster-0,
    aws_route_table_association.eks-private-ascrt-01-cluster-0,
    aws_route_table_association.eks-private-ascrt-02-cluster-0,
    aws_route_table_association.eks-public-ascrt-01-cluster-0,
    aws_route_table_association.eks-public-ascrt-02-cluster-0,
    aws_route.eks-public-r-cluster-0,
    aws_route.eks-private-r-01-cluster-0,
    aws_route.eks-private-r-02-cluster-0,
    aws_iam_role_policy_attachment.eksclusterpolicy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}