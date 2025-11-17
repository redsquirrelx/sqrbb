terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
    origin_group {
        origin_id = "failover"

        failover_criteria {
            status_codes = [ 403, 404, 500, 502 ]
        }

        member {
            origin_id = "custom_origin"
        }

        member {
            origin_id = "failover_origin"
        }
    }

    origin {
        origin_id = "custom_origin"
        domain_name = var.mrap_domain_name

        custom_origin_config {
          http_port = 80
          https_port = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols = [ "TLSv1.2" ]
        }
    }

    origin {
        origin_id = "failover_origin"
        domain_name = var.mrap_domain_name

        custom_origin_config {
          http_port = 80
          https_port = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols = [ "TLSv1.2" ]
        }
    }

    aliases = [ var.domain_name ]

    default_cache_behavior {
        target_origin_id        = "custom_origin"
        viewer_protocol_policy  = "redirect-to-https"
        allowed_methods         = [ "GET", "HEAD" ]
        cached_methods          = [ "GET", "HEAD" ]

        cache_policy_id = data.aws_cloudfront_cache_policy.CachingOptimized.id
        response_headers_policy_id = data.aws_cloudfront_response_headers_policy.SecurityHeadersPolicy.id
    }

    restrictions {
        geo_restriction {
            restriction_type = "blacklist"
            locations = [ "KP", "TF", "BV", "SJ" ]
        }
    }
    
    viewer_certificate {
        cloudfront_default_certificate = false
        minimum_protocol_version = "TLSv1.2_2018"
        acm_certificate_arn = var.acm_cert_arn
        ssl_support_method = "sni-only"
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

    depends_on = [ var.acm_cert_validation ]

    web_acl_id = aws_wafv2_web_acl.pass_acl.arn
}

data "aws_cloudfront_cache_policy" "CachingOptimized" {
    name = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "SecurityHeadersPolicy" {
    name = "Managed-SecurityHeadersPolicy"
}

resource "aws_wafv2_web_acl" "pass_acl" {
# checkov:skip=CKV2_AWS_31
    name        = "cloudfront-rules"
    scope       = "CLOUDFRONT"
    region = "us-east-1"

    default_action {
        allow {}
    }

    rule {
        name     = "AWSManagedRulesAnonymousIpList"
        priority = 1

        override_action {
            none {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesAnonymousIpList"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "rule-2-metric"
            sampled_requests_enabled   = true
        }
    }

    rule {
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
        priority = 2

        override_action {
            none {}
        }

        statement {
            managed_rule_group_statement {
                name        = "AWSManagedRulesKnownBadInputsRuleSet"
                vendor_name = "AWS"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name                = "rule-1-metrics"
            sampled_requests_enabled   = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "waf-metric"
        sampled_requests_enabled   = true
    }
}

resource "aws_route53_record" "www" {
    zone_id = var.hosted_zone_zone_id
    name    = var.domain_name
    type    = "A"

    alias {
        name = aws_cloudfront_distribution.s3_distribution.domain_name
        zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
        evaluate_target_health = true
    }
}