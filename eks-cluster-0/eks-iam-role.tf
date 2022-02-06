resource "aws_iam_role" "eks-clusterrole-0" {
  name = "eks-clusterrole-0"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "eks.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "eksclusterpolicy" {
  role       = aws_iam_role.eks-clusterrole-0.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  depends_on = [
    aws_iam_role.eks-clusterrole-0
  ]
}


resource "aws_iam_role" "eks-wnode-iam-role-cluster-0" {
  name = "eks-wnode-iam-role-cluster-0"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-wnode-iam-role-cluster-0.name
  depends_on = [
    aws_iam_role.eks-wnode-iam-role-cluster-0
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-wnode-iam-role-cluster-0.name
  depends_on = [
    aws_iam_role.eks-wnode-iam-role-cluster-0
  ]
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-wnode-iam-role-cluster-0.name
  depends_on = [
    aws_iam_role.eks-wnode-iam-role-cluster-0
  ]
}