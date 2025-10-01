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

data "aws_iam_policy_document" "origin_bucket_policy" {
    statement {
        sid    = "AllowCloudFrontServicePrincipalReadWrite"
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = ["cloudfront.amazonaws.com"]
        }
        actions = [
            "s3:GetObject",
            "s3:PutObject",
        ]
        resources = [
            "${aws_s3_bucket.this.arn}/*",
        ]
        condition {
            test     = "StringEquals"
            variable = "AWS:SourceArn"
            values   = [aws_cloudfront_distribution.s3_distribution.arn]
        }
    }
}

resource "aws_s3_bucket_policy" "this" {
    bucket = aws_s3_bucket.this.bucket
    policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

locals {
  origin_id = "s3Origin"
}

resource "aws_cloudfront_origin_access_control" "default" {
    name                              = "default-oac"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin {
        domain_name              = aws_s3_bucket.this.bucket_regional_domain_name
        origin_access_control_id = aws_cloudfront_origin_access_control.default.id
        origin_id = local.origin_id
    }

    default_cache_behavior {
        target_origin_id        = local.origin_id
        viewer_protocol_policy  = "allow-all"
        allowed_methods         = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT" ]
        cached_methods          = [ "GET", "HEAD" ]

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
    
    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        Name = "Sqrbb"
    }

    enabled = true
    default_root_object = "index.html"
}