terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "repo_lifecycle_policy" {
    type = string
    default = <<POLICY
{
    "rules": [
        {
            "rulePriority": 1,
            "selection": {
                "tagStatus": "untagged",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
POLICY
}

resource "aws_ecr_repository" "msrvc-reservas" {
    name                 = "msrvc/reservas"
    image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_repository" "msrvc-propiedades" {
    name                 = "msrvc/propiedades"
    image_tag_mutability = "IMMUTABLE"
}

resource "aws_ecr_lifecycle_policy" "reservas" {
    repository = aws_ecr_repository.msrvc-reservas.name
    policy = var.repo_lifecycle_policy
}

resource "aws_ecr_lifecycle_policy" "propiedades" {
    repository = aws_ecr_repository.msrvc-propiedades.name
    policy = var.repo_lifecycle_policy
}