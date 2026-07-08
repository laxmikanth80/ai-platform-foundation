# ADR 0002: Use community Terraform modules for VPC + EKS, not hand-rolled resources

## Status
Accepted

## Context
Chapter 1 needs a VPC and an EKS cluster as the base platform every later chapter deploys onto.
There were two realistic ways to build this in Terraform:

1. Write every underlying AWS resource by hand — subnets, route tables, NAT gateway, internet
   gateway, EKS cluster, node group, the IAM roles and OIDC provider EKS needs, security groups,
   KMS key for secrets encryption, etc.
2. Use `terraform-aws-modules/vpc/aws` and `terraform-aws-modules/eks/aws` — community modules
   that wrap all of the above behind a much smaller set of inputs, and are what most companies
   running EKS actually use in production.

## Decision
Use the community modules:
- `terraform-aws-modules/vpc/aws ~> 5.0`
- `terraform-aws-modules/eks/aws ~> 20.0`

Configuration choices made inside them, and why:
- **Single NAT gateway** (`single_nat_gateway = true`) instead of one per AZ — cuts NAT cost
  roughly 3x for a personal sandbox account; a real production account would likely want
  AZ-redundant NAT instead.
- **2 availability zones**, not 3 — EKS requires a minimum of 2 for the control plane; a third
  costs an extra subnet/NAT setup for marginal benefit at this scale.
- **A single `t3.medium` on-demand node** to start — small and cheap enough to validate the
  cluster works; GPU node groups are deliberately out of scope here and come in Chapter 5.
- **`terraform plan` reviewed (53 resources to add), but `terraform apply` deliberately deferred**
  to Week 2, when the cluster is immediately put to use (first service deployed through the
  pipeline) instead of sitting idle and accumulating cost (EKS control plane + NAT + node run to
  roughly $135-140/month combined if left running continuously) between now and then.

## Consequences
- **Gain:** far less code to write and maintain; these modules are battle-tested at a scale no
  personal project could realistically replicate testing for, and they encode sane defaults
  (e.g. correct subnet tagging for EKS load balancer discovery) that are easy to get wrong by hand.
- **Cost:** understanding is at the level of the module's *inputs and outputs*, not every resource
  it creates internally — if something inside the module misbehaves, debugging requires reading
  the module's source, not just this repo's. This repo is also now dependent on a third-party
  module staying maintained and compatible with future Terraform/provider versions.
- **Trade-off accepted deliberately:** for a portfolio/learning project, the goal is understanding
  how to *configure and operate* production-grade infrastructure, not re-deriving every AWS
  networking primitive from scratch — the equivalent of using a well-known library instead of
  reimplementing it, which is the same judgment call made constantly in real engineering work.
