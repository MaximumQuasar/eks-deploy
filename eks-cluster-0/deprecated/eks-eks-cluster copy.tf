module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = "eks-cluster-0"
  cluster_version                 = "1.21"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  create_cluster_security_group   = false

  cluster_security_group_id       = local.eks-resources.cluster-sg

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  vpc_id     = local.eks-resources.cluster-vpc
  subnet_ids = local.eks-resources.cluster-subnet_ids

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 50
    instance_types         = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      tags = {
        ExtraTag = "example"
      }
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  depends_on = [
    aws_nat_gateway.eks-private-ngw-02-cluster-0,
    aws_nat_gateway.eks-private-ngw-01-cluster-0,
    aws_route_table_association.eks-private-ascrt-01-cluster-0,
    aws_route_table_association.eks-private-ascrt-02-cluster-0,
    aws_route_table_association.eks-public-ascrt-01-cluster-0,
    aws_route_table_association.eks-public-ascrt-02-cluster-0,
    aws_route.eks-public-r-cluster-0,
    aws_route.eks-private-r-01-cluster-0,
    aws_route.eks-private-r-02-cluster-0
  ]
}

locals "eks-resources" {
    cluster-sg  = aws_security_group.eks-controlplane-sg-cluster-0.id
    cluster-vpc = aws_vpc.eks-vpc-cluster-0.id
    cluster-subnet_ids = [aws_subnet.eks-sbn-private-02-cluster-0.id,aws_subnet.eks-sbn-private-01-cluster-0.id,aws_subnet.eks-sbn-public-02-cluster-0.id,aws_subnet.eks-sbn-public-01-cluster-0.id]
}