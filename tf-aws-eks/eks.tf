module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "~> 20"

    cluster_name = var.cluster_name
    cluster_version = "1.31"

    cluster_endpoint_public_access  = true
    vpc_id                   = module.vpc.vpc_id
    subnet_ids               = module.vpc.private_subnets

    # EKS Managed Node Group(s)
    eks_managed_node_groups = {
        nodes = {
        min_size     = 1
        max_size     = 2
        desired_size = 1

        instance_types = ["t2.small"]
        capacity_type  = "SPOT"
        }
    }
    enable_cluster_creator_admin_permissions = true

    tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}