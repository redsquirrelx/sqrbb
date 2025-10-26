terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_s3_bucket" "access_logs" {
# checkov:skip=CKV_AWS_144:No necesita replicación cross-region
# checkov:skip=CKV2_AWS_62:No necesita event notifications
# checkov:skip=CKV_AWS_18:No necesita access logging

    bucket = "redsqx-access-logs"

    tags = {
        Name = "Logs"
    }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
    bucket = aws_s3_bucket.access_logs.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
    bucket = aws_s3_bucket.access_logs.bucket

    rule {
        id = "1"
        status = "Enabled"

        filter {
            prefix = "AWSLogs/"
        }

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

data "aws_iam_policy_document" "alb_access_logs" {
    statement {
        sid = "PermitirALBAccessLog"
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = [ "logdelivery.elasticloadbalancing.amazonaws.com" ]
        }
        actions = [ "s3:PutObject" ]
        resources = [ "${aws_s3_bucket.access_logs.arn}/AWSLogs/*" ]
    }
}

resource "aws_s3_bucket_policy" "access_logs" {
    bucket = aws_s3_bucket.access_logs.bucket
    policy = data.aws_iam_policy_document.alb_access_logs.json
}
