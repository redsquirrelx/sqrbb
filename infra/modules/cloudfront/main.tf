terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
# checkov:skip=CKV_AWS_310:failover manejado por MRAP
# checkov:skip=CKV_AWS_86:no necesita access logging

    origin {
        origin_id = "custom_origin"
        domain_name = var.mrap.domain_name

        custom_origin_config {
          http_port = 80
          https_port = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols = [ "TLSv1.2" ]
        }
    }

    default_cache_behavior {
        target_origin_id        = "custom_origin"
        viewer_protocol_policy  = "redirect-to-https"
        allowed_methods         = [ "GET", "HEAD" ]
        cached_methods          = [ "GET", "HEAD" ]

        # Para CachingOptimized
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

        # Para Managed-SecurityHeadersPolicy
        response_headers_policy_id = data.aws_cloudfront_response_headers_policy.SecurityHeadersPolicy.id
    }

    restrictions {
        geo_restriction {
            restriction_type = "blacklist"
            locations = [ "KP", "TF", "BV", "SJ" ]
        }
    }
    
    viewer_certificate {
        cloudfront_default_certificate = true
    }

    tags = {
        Name = "sqrbx web dist"
    }

    enabled = true
    default_root_object = "index.html"

    lifecycle {
        ignore_changes = [ 
            default_cache_behavior[0].lambda_function_association
        ]
    }
}

data "aws_cloudfront_response_headers_policy" "SecurityHeadersPolicy" {
    name = "Managed-SecurityHeadersPolicy"
}