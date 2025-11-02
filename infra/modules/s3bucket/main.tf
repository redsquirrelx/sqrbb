terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

resource "aws_s3_bucket" "this" {
# checkov:skip=CKV_AWS_144:No necesita replicación cross-region
# checkov:skip=CKV2_AWS_62:No necesita event notifications
# checkov:skip=CKV_AWS_18:No necesita access logging
    region = var.region

    bucket = var.bucket_name
    force_destroy = true

    tags = {
      Name = "${var.bucket_name}"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    bucket = aws_s3_bucket.this.bucket
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    bucket = aws_s3_bucket.this.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_public_access_block" "this" {
    bucket = aws_s3_bucket.this.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}