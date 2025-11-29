output "actualizar_estadisticas_sg_id" {
    value = aws_security_group.actualizar_estadisticas.id
}

output "lambda_actualizar_estadisticas_arn" {
    value = module.actualizar_estadisticas.lambda_arn
}

output "signer_actualizar_estadisticas_arn" {
    value = module.actualizar_estadisticas.signer_name
}

output "enviar_correo_sg_id" {
    value = aws_security_group.enviar_correo.id
}

output "lambda_enviar_correo_arn" {
    value = module.enviar_correo.lambda_arn
}

output "signer_enviar_correo_arn" {
    value = module.enviar_correo.signer_name
}

# SES
output "ses_domain_identity_verification_token" {
    value = aws_ses_domain_identity.this.verification_token  
}

output "ses_domain_dkim_tokens" {
    value = aws_ses_domain_dkim.this.dkim_tokens
}

output "ses_domain_mail_from_domain" {
    value = aws_ses_domain_mail_from.this.mail_from_domain
}

# SQS
output "reserva_topic_arn" {
    value = aws_sns_topic.reserva_proc.arn
}