output "cloudfront_dist_id" {
    value = module.cloudfront.cloudfront-dist-id
}

output "aws_account_id" {
    value = data.aws_caller_identity.current.account_id
}

output "lmbd_fn_sigv4a_arn" {
    value = module.lambda.lambda-fn-sigv4a.function_name
}

output "sigv4a_signer_name" {
    value = module.lambda.sigv4a-signer-name
}

output "cluster_main_name" {
    value = module.services.cluster-main.name
}

output "propiedades_td_arn" {
    value = module.services.propiedades_td_arn
}

output "reservas_td_arn" {
    value = module.services.reservas_td_arn
}

output "lambda_actualizar_estadisticas_us-east-2_arn" {
    value = module.actualizar_estadisticas.lambda_arn
}

output "signer_actualizar_estadisticas_us-east-2_arn" {
    value = module.actualizar_estadisticas.signer_name
}

output "lambda_bucket_us-east-2" {
    value = module.bucket_lambda_us_east_2.bucket
}