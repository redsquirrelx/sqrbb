terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.14.1"
        configuration_aliases = [ aws.ue2, aws.ue1, aws.se1, aws.ew1 ]
    }
  }
}

resource "aws_s3_bucket" "us-east-2" {
# checkov:skip=CKV2_AWS_61:No necesita lifecycle rules
# checkov:skip=CKV_AWS_144:No necesita replicación cross-region
# checkov:skip=CKV2_AWS_62:No necesita event notifications

    provider = aws.ue2

    bucket = "redsqx-us-east-2-web-dist"
    force_destroy = true
    
    tags = {
      Name = "redsqx us-east-2 web dist"
    }
}

resource "aws_s3_bucket" "sa-east-1" {
# checkov:skip=CKV2_AWS_61:No necesita lifecycle rules
# checkov:skip=CKV_AWS_144:No necesita replicación cross-region
# checkov:skip=CKV2_AWS_62:No necesita event notifications

    provider = aws.se1

    bucket = "redsqx-sa-east-1-web-dist"
    force_destroy = true

    tags = {
      Name = "redsqx sa-east-1 web dist"
    }
}

resource "aws_s3_bucket" "eu-west-1" {
# checkov:skip=CKV2_AWS_61:No necesita lifecycle rules
# checkov:skip=CKV_AWS_144:No necesita replicación cross-region
# checkov:skip=CKV2_AWS_62:No necesita event notifications

    provider = aws.ew1

    bucket = "redsqx-eu-west-1-web-dist"
    force_destroy = true

    tags = {
      Name = "redsqx eu-west-1 web dist"
    }
}

resource "aws_s3_bucket_versioning" "us-east-2" {
    provider = aws.ue2
    bucket = aws_s3_bucket.us-east-2.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_versioning" "sa-east-1" {
    provider = aws.se1
    bucket = aws_s3_bucket.sa-east-1.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_versioning" "eu-west-1" {
    provider = aws.ew1
    bucket = aws_s3_bucket.eu-west-1.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_public_access_block" "us-east-2" {
    provider = aws.ue2
    bucket = aws_s3_bucket.us-east-2.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "sa-east-1" {
    provider = aws.se1
    bucket = aws_s3_bucket.sa-east-1.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "eu-west-1" {
    provider = aws.ew1
    bucket = aws_s3_bucket.eu-west-1.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3control_multi_region_access_point" "staticpage" {
    details {
        name = "redsqx-mrap-web-dist"

        region {
            bucket = aws_s3_bucket.us-east-2.id
        }

        region {
            bucket = aws_s3_bucket.sa-east-1.id
        }
        
        region {
            bucket = aws_s3_bucket.eu-west-1.id
        }
    }
}