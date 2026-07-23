variable "aws_region" {
  description = "AWS region for the platform foundation"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Used as a tag/prefix on every resource — required for the Ch.8 cost dashboard to work without archaeology"
  type        = string
  default     = "ai-platform-foundation"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC — /16 gives plenty of room to subnet without ever needing to redo this later"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "2 AZs is the minimum for EKS (control plane requires subnets in >= 2 AZs); 3 costs more (extra NAT/subnets) for marginal benefit at this scale"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "Where EKS worker nodes live — no direct route to the internet, egress only via NAT"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Where load balancers and the single NAT gateway live"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "eks_cluster_version" {
  description = <<-EOT
    Kubernetes version for the EKS control plane. Must stay within AWS's
    STANDARD support window — once a version ages out, AWS silently switches
    to ExtendedSupport billing at ~5x the normal control-plane rate (this bit
    us: 1.30 alone added ~$40 in a few days). Check current standard-support
    versions before ever changing this:
    aws eks describe-cluster-versions --query "clusterVersions[?clusterVersionPolicy=='STANDARD']"
  EOT
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for the default (non-GPU) node group — GPU node groups come later, in Ch.5"
  type        = string
  default     = "t3.medium"
}

variable "github_org" {
  description = "GitHub org/user that owns this repo — scopes which workflow runs can assume the CI IAM role via OIDC"
  type        = string
  default     = "laxmikanth80"
}

variable "github_repo" {
  description = "Repo name — combined with github_org to scope the OIDC trust condition"
  type        = string
  default     = "ai-platform-foundation"
}
