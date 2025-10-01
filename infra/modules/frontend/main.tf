terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.14.1"
    }
  }
}

resource "aws_s3_bucket" "this" {
    bucket = "redsqx-static-web-front"
    force_destroy = true

    tags = {
      Name = "redsqx-static-web-front"
    }
}

