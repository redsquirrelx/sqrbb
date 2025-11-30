output "cloudfront_dist_id" {
    value = module.cloudfront.cloudfront-dist-id
}

output "aws_account_id" {
    value = data.aws_caller_identity.current.account_id
}

# Servicios

output "ecs_cluster_names" {
    value = {
        us-east-2 = module.services_us_east_2.cluster-main.name
        eu-west-1 = module.services_eu_west_1.cluster-main.name
    }
}

output "propiedades_td_arns" {
    value = {
        us-east-2 = module.services_us_east_2.propiedades_td_arn
        eu-west-1 = module.services_eu_west_1.propiedades_td_arn
    }
}

output "reservas_td_arns" {
    value = {
        us-east-2 = module.services_us_east_2.reservas_td_arn
        eu-west-1 = module.services_eu_west_1.reservas_td_arn
    }
}

# LAMBDAS

output "lmbd_fn_sigv4a_arn" {
    value = module.sigv4a.lambda-fn-sigv4a.function_name
}

output "sigv4a_signer_name" {
    value = module.sigv4a.sigv4a-signer-name
}

output "lambda_actualizar_estadisticas" {
    value = {
        us-east-2 = {
            lambda_arn = module.regional_us_east_2.lambda_actualizar_estadisticas_arn
            signer_arn = module.regional_us_east_2.signer_actualizar_estadisticas_arn
        }
        eu-west-1 = {
            lambda_arn = module.regional_eu_west_1.lambda_actualizar_estadisticas_arn
            signer_arn = module.regional_eu_west_1.signer_actualizar_estadisticas_arn
        }
    }
}

output "lambda_enviar_correo" {
    value = {
        us-east-2 = {
            lambda_arn = module.regional_us_east_2.lambda_enviar_correo_arn
            signer_arn = module.regional_us_east_2.signer_enviar_correo_arn
        }
        eu-west-1 = {
            lambda_arn = module.regional_eu_west_1.lambda_enviar_correo_arn
            signer_arn = module.regional_eu_west_1.signer_enviar_correo_arn
        }
    }
}

output "lambda_bucket" {
    value = {
        us-east-2 = module.bucket_lambda_us_east_2.bucket
        eu-west-1 = module.bucket_lambda_eu_west_1.bucket
    }
}