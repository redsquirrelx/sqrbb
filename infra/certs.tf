# Certificado para cloudfront
resource "aws_acm_certificate" "us_east_1" {
    provider = aws.ue1

    domain_name       = var.domain_name
    validation_method = "DNS"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route53_record" "us_east_1_cert" {
    provider = aws.ue1

    for_each = {
        for dvo in aws_acm_certificate.us_east_1.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = each.value.type
    zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "us_east_1" {
    provider = aws.ue1

    certificate_arn         = aws_acm_certificate.us_east_1.arn
    validation_record_fqdns = [for record in aws_route53_record.us_east_1_cert : record.fqdn]
}

# Certificados para apigateway
locals {
    certificados = {
        us-east-2 = {}
        eu-west-1 = {}
    }
}

resource "aws_acm_certificate" "api" {
    for_each = local.certificados
    region = each.key

    domain_name       = var.domain_name
    validation_method = "DNS"

    subject_alternative_names = [
        "api.${ var.domain_name }"
    ]

    lifecycle {
        create_before_destroy = true
    }

    depends_on = [ aws_acm_certificate_validation.us_east_1 ]
}

resource "aws_route53_record" "api_cert" {
    for_each = {
        for dvo in aws_acm_certificate.api["us-east-2"].domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = each.value.type
    zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_route53_record" "api_cert_eu_west_1" {
    for_each = {
        for dvo in aws_acm_certificate.api["eu-west-1"].domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            record = dvo.resource_record_value
            type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 60
    type            = each.value.type
    zone_id         = aws_route53_zone.this.zone_id
}

resource "aws_acm_certificate_validation" "api_cert_val" {
    region = "us-east-2"

    certificate_arn         = aws_acm_certificate.api["us-east-2"].arn
    validation_record_fqdns = [for record in aws_route53_record.api_cert : record.fqdn]
}

resource "aws_acm_certificate_validation" "api_cert_val_eu_west_1" {
    region = "eu-west-1"

    certificate_arn         = aws_acm_certificate.api["eu-west-1"].arn
    validation_record_fqdns = [for record in aws_route53_record.api_cert : record.fqdn]
}