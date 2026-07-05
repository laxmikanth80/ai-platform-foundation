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
