terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_ecs_cluster" "this" {
    name = "main-cluster"

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}