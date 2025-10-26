terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
# checkov:skip=CKV_AWS_310:failover manejado por MRAP

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