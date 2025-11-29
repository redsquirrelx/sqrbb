resource "aws_route53_zone" "this" {
    name = var.domain_name
}

resource "aws_route53_key_signing_key" "this" {
    hosted_zone_id             = aws_route53_zone.this.id
    key_management_service_arn = aws_kms_key.dnssec.arn
    name                       = "ksk"
}

resource "aws_route53_hosted_zone_dnssec" "this" {
    depends_on = [
        aws_route53_key_signing_key.this,
        aws_acm_certificate_validation.api_cert_val
    ]
    hosted_zone_id = aws_route53_key_signing_key.this.hosted_zone_id
}

resource "aws_route53_query_log" "route53" {
    depends_on               = [ aws_cloudwatch_log_resource_policy.route53_query_logging ]
    zone_id                  = aws_route53_zone.this.id
    cloudwatch_log_group_arn = module.route53_loggroup.log_group_arn
}

data "aws_iam_policy_document" "route53_query_logging" {
    statement {
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]

        resources = [
            "${module.route53_loggroup.log_group_arn}:*"
        ]

        principals {
            identifiers = ["route53.amazonaws.com"]
            type        = "Service"
        }
    }
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging" {
    region = "us-east-1"

    policy_document = data.aws_iam_policy_document.route53_query_logging.json
    policy_name     = "route53-query-logging"
}

# Actualizar dominio registrado con los nuevos NS
resource "aws_route53domains_registered_domain" "this" {
    domain_name = var.domain_name

    dynamic "name_server" {
        for_each = toset(aws_route53_zone.this.name_servers)
        content {
            name = name_server.value
        }
    }

    transfer_lock = true
    auto_renew    = false
}

resource "aws_route53_record" "api_us_east_2" {
    zone_id = aws_route53_zone.this.zone_id
    type = "A"
    name = "api.${var.domain_name}"

    alias {
        name = module.api_gateway_us_east_2.target_domain_name
        zone_id = module.api_gateway_us_east_2.hosted_zone_id
        evaluate_target_health = true
    }

    latency_routing_policy {
        region = "us-east-2"
    }

    set_identifier = "api_us_east_2"
}

resource "aws_route53_record" "api_eu_west_1" {
    zone_id = aws_route53_zone.this.zone_id
    type = "A"
    name = "api.${var.domain_name}"

    alias {
        name = module.api_gateway_eu_west_1.target_domain_name
        zone_id = module.api_gateway_eu_west_1.hosted_zone_id
        evaluate_target_health = true
    }

    latency_routing_policy {
        region = "eu-west-1"
    }

    set_identifier = "api_eu_west_1"
}