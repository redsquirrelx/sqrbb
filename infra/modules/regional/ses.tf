resource "aws_ses_domain_identity" "this" {
    region = var.region
    domain = var.domain_name
}

resource "aws_ses_domain_dkim" "this" {
    region = var.region
    domain = aws_ses_domain_identity.this.domain
}

resource "aws_ses_domain_mail_from" "this" {
    region = var.region
    domain           = aws_ses_domain_identity.this.domain
    mail_from_domain = "mail.${aws_ses_domain_identity.this.domain}"
}