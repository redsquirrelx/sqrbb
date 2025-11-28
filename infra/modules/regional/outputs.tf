output "actualizar_estadisticas_sg_id" {
    value = aws_security_group.actualizar_estadisticas.id
}

output "lambda_actualizar_estadisticas_arn" {
    value = module.actualizar_estadisticas.lambda_arn
}

output "signer_actualizar_estadisticas_arn" {
    value = module.actualizar_estadisticas.signer_name
}