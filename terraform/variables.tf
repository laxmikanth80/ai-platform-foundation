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
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.30"
}

variable "node_instance_type" {
  description = "EC2 instance type for the default (non-GPU) node group — GPU node groups come later, in Ch.5"
  type        = string
  default     = "t3.medium"
}
