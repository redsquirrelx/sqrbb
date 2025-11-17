terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

resource "aws_s3_bucket" "this" {
    region = var.region

    bucket = var.bucket_name
    force_destroy = true

    tags = {
      Name = "${var.bucket_name}"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    region = var.region

    bucket = aws_s3_bucket.this.bucket
    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_versioning" "this" {
    region = var.region

    bucket = aws_s3_bucket.this.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_public_access_block" "this" {
    region = var.region

    bucket = aws_s3_bucket.this.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "this" {
    region = var.region

    count = var.enable_access_logs ? 1 : 0

    bucket = aws_s3_bucket.this.bucket
    target_bucket = var.bucket_access_logs_bucket
    target_prefix = "/s3_bucket_logs/${var.bucket_name}"
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = ["s3.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "this" {
    count = var.replicate ? 1 : 0

    name               = "s3bucket-replication"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_s3_bucket_replication_configuration" "this" {
    region = var.region

    count = var.replicate ? 1 : 0

    bucket = aws_s3_bucket.this.id
    role = aws_iam_role.this[0].arn

    rule {
        status = "Enabled"
        destination {
            bucket = var.bucket_replicated_id
            storage_class = "STANDARD"
        }
    }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    region = var.region

    count = var.enable_event_notifs ? 1 : 0

    bucket = aws_s3_bucket.this.id

    topic {
        topic_arn     = var.sns_arn
        events        = ["s3:ObjectCreated:*"]
        filter_prefix = "logs/"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
    region = var.region
    
    bucket = aws_s3_bucket.this.id

    rule {
        id = "1"
        status = "Enabled"

        filter {}

        expiration {
          days = 365
        }
    }

    rule {
        id = "2"
        status = "Enabled"

        filter {}

        abort_incomplete_multipart_upload {
          days_after_initiation = 1
        }
    }
}