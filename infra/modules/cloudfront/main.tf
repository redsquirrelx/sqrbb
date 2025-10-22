terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
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

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
        
        lambda_function_association {
            event_type   = "origin-request"
            lambda_arn   = var.sigv4a-lmbd-fn.qualified_arn
            include_body = false
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
        Name = "sqrbx web dist"
    }

    enabled = true
    default_root_object = "index.html"
}