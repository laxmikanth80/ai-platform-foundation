locals {
  tags = {
    Project = var.project_name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # One NAT gateway instead of one per AZ — cuts NAT cost ~3x. Single point of
  # failure for outbound traffic, but a personal sandbox account doesn't need
  # AZ-redundant NAT; a real production account usually would.
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true

  # EKS uses these tags to know which subnets to put internet-facing vs.
  # internal load balancers in.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = var.eks_cluster_version

  # Defaults to false — without it, EKS access control (a separate system
  # from IAM permissions) never grants anyone Kubernetes RBAC access, even
  # the identity that ran `terraform apply`. This is what was missing:
  # platform-foundation-admin had full IAM AdministratorAccess but zero
  # Kubernetes-level access to this specific cluster.
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public access is required for kubectl from outside the VPC (your laptop);
  # the module's default left this off, which is why the endpoint had no
  # public DNS record at all. Left open to 0.0.0.0/0 for simplicity on a
  # personal sandbox account — a real production cluster would restrict
  # cluster_endpoint_public_access_cidrs to known office/VPN IP ranges
  # instead of leaving this wide open. Worth an ADR note.
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }

  tags = local.tags
}
