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