resource "aws_ses_domain_identity" "this" {
    region = var.region
    domain = var.domain_name
}

resource "aws_ses_domain_dkim" "this" {
    region = var.region
    domain = aws_ses_domain_identity.this.domain
}

resource "aws_route53_record" "ses_verificacion" {
    zone_id = var.route_53_zone_zone_id
    name    = "_amazonses.${var.domain_name}"
    type    = "TXT"
    ttl     = "600"
    records = [ aws_ses_domain_identity.this.verification_token ]
}

resource "aws_route53_record" "dkim_records" {
    count   = 3
    zone_id = var.route_53_zone_zone_id
    name    = "${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
    type    = "CNAME"
    ttl     = 600
    records = ["${element(aws_ses_domain_dkim.this.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "dmarc" {
    zone_id = var.route_53_zone_zone_id
    name    = "_dmarc.${var.domain_name}"
    type    = "TXT"
    ttl     = 300

    records = [
        "v=DMARC1; p=none; rua=mailto:dmarc-reports@${var.domain_name}; fo=1"
    ]
}

resource "aws_ses_domain_mail_from" "this" {
    domain           = aws_ses_domain_identity.this.domain
    mail_from_domain = "mail.${aws_ses_domain_identity.this.domain}"
}

resource "aws_route53_record" "spf" {
    zone_id = var.route_53_zone_zone_id
    name    = aws_ses_domain_mail_from.this.mail_from_domain
    type    = "TXT"
    ttl     = 600
    records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "mx" {
    zone_id = var.route_53_zone_zone_id
    name    = aws_ses_domain_mail_from.this.mail_from_domain
    type    = "MX"
    ttl     = "600"
    records = ["10 feedback-smtp.${var.region}.amazonses.com"]
}