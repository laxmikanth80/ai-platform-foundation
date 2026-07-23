resource "aws_ecr_repository" "platform_foundation" {
  name                 = var.project_name
  image_tag_mutability = "IMMUTABLE" # a pushed tag can never be overwritten — avoids
  # the "I redeployed but somehow got the old code" class of bug

  # Without this, `terraform destroy` refuses to delete a repo that still has
  # images in it — a reasonable default guard, but this project's whole model
  # is destroy-when-idle/recreate-when-needed to control cost, so requiring a
  # manual image cleanup before every destroy would defeat that habit. The
  # trade-off: a `destroy` here is a bit more "one command, no confirmation
  # step" destructive than the AWS default — acceptable on a personal sandbox
  # account, not something to do on a shared/production repo.
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true # free basic vulnerability scan on every push
  }

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "platform_foundation" {
  repository = aws_ecr_repository.platform_foundation.name

  # ECR storage is billed per GB/month — with weekly pushes over 6 months this
  # would otherwise grow unbounded for no benefit.
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {
  value = aws_ecr_repository.platform_foundation.repository_url
}
