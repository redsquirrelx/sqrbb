terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [ aws.ue2, aws.se1 ]
    }
  }
}

resource "aws_s3_bucket" "us-east-2" {
    provider = aws.ue2
    bucket = "redsqx-staticpage-us-east-2"
    force_destroy = true
    tags = {
        Name = "staticpage-us-east-2"
    }
}

resource "aws_s3_bucket_versioning" "us-east-2" {
    provider = aws.ue2
    bucket = aws_s3_bucket.us-east-2.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket" "sa-east-1" {
    provider = aws.se1
    bucket = "redsqx-staticpage-sa-east-1"
    force_destroy = true
    tags = {
        Name = "staticpage-sa-east-1"
    }
}

resource "aws_s3_bucket_versioning" "sa-east-1" {
    provider = aws.se1
    bucket = aws_s3_bucket.sa-east-1.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3control_multi_region_access_point" "staticpage" {
    details {
        name = "redsqx-staticpage"

        region {
            bucket = aws_s3_bucket.us-east-2.id
        }

        region {
            bucket = aws_s3_bucket.sa-east-1.id
        }
    }
}