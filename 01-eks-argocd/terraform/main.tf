data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Project     = "k8s-platform-lab"
    Environment = "lab"
    ManagedBy   = "terraform"
  }
}

# --- VPC (public subnets only to avoid NAT Gateway cost) ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway      = false
  single_nat_gateway      = false
  map_public_ip_on_launch = true     # ← ДОБАВЬ ЭТУ СТРОКУ

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = local.tags
}

# --- EKS cluster ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      subnet_ids = module.vpc.public_subnets
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = local.tags
}