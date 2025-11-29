resource "aws_route53_record" "ses_verificacion" {
    zone_id = aws_route53_zone.this.zone_id
    name    = "_amazonses.${var.domain_name}"
    type    = "TXT"
    ttl     = "600"
    records = [
        module.regional_us_east_2.ses_domain_identity_verification_token,
        module.regional_eu_west_1.ses_domain_identity_verification_token
    ]
}

resource "aws_route53_record" "dkim_records_us_east_2" {
    count   = 3
    zone_id = aws_route53_zone.this.zone_id
    name    = "${element(module.regional_us_east_2.ses_domain_dkim_tokens, count.index)}._domainkey.${var.domain_name}"
    type    = "CNAME"
    ttl     = 600
    records = ["${element(module.regional_us_east_2.ses_domain_dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "dkim_records_eu_west_1" {
    count   = 3
    zone_id = aws_route53_zone.this.zone_id
    name    = "${element(module.regional_eu_west_1.ses_domain_dkim_tokens, count.index)}._domainkey.${var.domain_name}"
    type    = "CNAME"
    ttl     = 600
    records = ["${element(module.regional_eu_west_1.ses_domain_dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "dmarc" {
    zone_id = aws_route53_zone.this.zone_id
    name    = "_dmarc.${var.domain_name}"
    type    = "TXT"
    ttl     = 300

    records = [
        "v=DMARC1; p=none; rua=mailto:dmarc-reports@${var.domain_name}; fo=1"
    ]
}

resource "aws_route53_record" "spf" {
    zone_id = aws_route53_zone.this.zone_id
    name    = module.regional_us_east_2.ses_domain_mail_from_domain
    type    = "TXT"
    ttl     = 600
    records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "mx" {
    zone_id = aws_route53_zone.this.zone_id
    name    = module.regional_us_east_2.ses_domain_mail_from_domain
    type    = "MX"
    ttl     = "600"
    records = [
        "10 feedback-smtp.us-east-2.amazonses.com",
        "10 feedback-smtp.eu-west-1.amazonses.com"
    ]
}