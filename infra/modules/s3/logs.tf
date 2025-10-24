terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_s3_bucket" "access_logs" {
    bucket = "redsqx-access-logs"

    tags = {
        Name = "Logs"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
    bucket = aws_s3_bucket.access_logs.bucket

    rule {
        id = "1"
        filter {
            prefix = "AWSLogs/"
        }
        expiration {
          days = 365
        }
        status = "Enabled"
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
