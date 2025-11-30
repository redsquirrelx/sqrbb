data "aws_caller_identity" "current" { }

module "vpc_us_east_2" {
    source = "./modules/network"

    flow_log_group_arn = module.vpc_loggroup.log_group_arn
    region = "us-east-2"

    providers = {
        aws = aws.ue2
    }
}

module "vpc_eu_west_1" {
    source = "./modules/network"

    flow_log_group_arn = module.vpc_loggroup_eu_west_1.log_group_arn
    region = "eu-west-1"

    providers = {
        aws = aws.ew1
    }
}

module "regional_us_east_2" {
    source = "./modules/regional"
    region = "us-east-2"

    kms_arn = aws_kms_key.kms["us-east-2"].arn
    lambda_bucket_bucket = module.bucket_lambda_us_east_2.bucket
    lambda_bucket_id = module.bucket_lambda_us_east_2.bucket_id
    lambda_subnets = module.vpc_us_east_2.lambda_subnets
    vpc_id = module.vpc_us_east_2.vpc-id
    account_id = data.aws_caller_identity.current.account_id
    route_53_zone_zone_id = aws_route53_zone.this.zone_id
    domain_name = var.domain_name
    lambda_kms_key_arn = aws_kms_key.lambda["us-east-2"].arn

    updateStats_sg_id = module.vpc_us_east_2.updateStats_sg_id
    sendEmail_sg_id = module.vpc_us_east_2.sendEmail_sg_id
}

module "regional_eu_west_1" {
    source = "./modules/regional"
    region = "eu-west-1"

    kms_arn = aws_kms_key.kms["eu-west-1"].arn
    lambda_bucket_bucket = module.bucket_lambda_eu_west_1.bucket
    lambda_bucket_id = module.bucket_lambda_eu_west_1.bucket_id
    lambda_subnets = module.vpc_eu_west_1.lambda_subnets
    vpc_id = module.vpc_eu_west_1.vpc-id
    account_id = data.aws_caller_identity.current.account_id
    route_53_zone_zone_id = aws_route53_zone.this.zone_id
    domain_name = var.domain_name
    lambda_kms_key_arn = aws_kms_key.lambda["eu-west-1"].arn

    updateStats_sg_id = module.vpc_eu_west_1.updateStats_sg_id
    sendEmail_sg_id = module.vpc_eu_west_1.sendEmail_sg_id
}

module "alb_us_east_2" {
    source = "./modules/alb"
    vpc-id = module.vpc_us_east_2.vpc-id
    alb-sg = module.vpc_us_east_2.alb-sg
    alb-subnets = module.vpc_us_east_2.alb-subnets
    access_logs_bucket_id = module.bucket_access_logs["us-east-2"].bucket_id
    acm_cert_arn = aws_acm_certificate.api["us-east-2"].arn
    acm_cert_validation = aws_acm_certificate_validation.api_cert_val_us_east_2

    providers = {
      aws = aws.ue2
    }
}

module "alb_eu_west_1" {
    source = "./modules/alb"
    vpc-id = module.vpc_eu_west_1.vpc-id
    alb-sg = module.vpc_eu_west_1.alb-sg
    alb-subnets = module.vpc_eu_west_1.alb-subnets
    access_logs_bucket_id = module.bucket_access_logs["eu-west-1"].bucket_id
    acm_cert_arn = aws_acm_certificate.api["eu-west-1"].arn
    acm_cert_validation = aws_acm_certificate_validation.api_cert_val_eu_west_1

    providers = {
      aws = aws.ew1
    }
}

module "ecr_us_east_2" {
    source = "./modules/ecr"

    providers = {
      aws = aws.ue2
    }
}

module "ecr_eu_west_1" {
    source = "./modules/ecr"

    providers = {
      aws = aws.ew1
    }
}

# Temporal
locals {
    microservices  = {
        us-east-2 = {
            propiedades = {
                repository_url = module.ecr_us_east_2.propiedades_repository.repository_url,
                security_group_id = module.vpc_us_east_2.service-sg.id
                subnets_ids = [ module.vpc_us_east_2.service-subnets[0].id ]
                target_group_arn = module.alb_us_east_2.propiedades-tg.arn
            }
            reservas = {
                repository_url = module.ecr_us_east_2.reservas_repository.repository_url,
                security_group_id = module.vpc_us_east_2.service-sg.id
                subnets_ids = [ module.vpc_us_east_2.service-subnets[0].id ]
                target_group_arn = module.alb_us_east_2.reservas-tg.arn
                topic_arn = module.regional_us_east_2.reserva_topic_arn
                kms_arn = aws_kms_key.kms["us-east-2"].arn
            }
        }

        eu-west-1 = {
            propiedades = {
                repository_url = module.ecr_eu_west_1.propiedades_repository.repository_url,
                security_group_id = module.vpc_eu_west_1.service-sg.id
                subnets_ids = [ module.vpc_eu_west_1.service-subnets[0].id ]
                target_group_arn = module.alb_eu_west_1.propiedades-tg.arn
            }
            reservas = {
                repository_url = module.ecr_eu_west_1.reservas_repository.repository_url,
                security_group_id = module.vpc_eu_west_1.service-sg.id
                subnets_ids = [ module.vpc_eu_west_1.service-subnets[0].id ]
                target_group_arn = module.alb_eu_west_1.reservas-tg.arn
                topic_arn = module.regional_eu_west_1.reserva_topic_arn
                kms_arn = aws_kms_key.kms["eu-west-1"].arn
            }
        }
    }
}

module "services_us_east_2" {
    source = "./modules/services"
    region = "us-east-2"
    vpc_id = module.vpc_us_east_2.vpc-id

    service_data = local.microservices.us-east-2
    account_id = data.aws_caller_identity.current.account_id
    domain_name = var.domain_name

    providers = {
        aws = aws.ue2
    }
}

module "services_eu_west_1" {
    source = "./modules/services"
    region = "eu-west-1"
    vpc_id = module.vpc_eu_west_1.vpc-id

    service_data = local.microservices.eu-west-1
    account_id = data.aws_caller_identity.current.account_id
    domain_name = var.domain_name

    providers = {
        aws = aws.ew1
    }
}

module "api_gateway_us_east_2" {
    source = "./modules/api-gateway"

    vpc-link-sg = module.vpc_us_east_2.vpc-link-sg
    alb-subnets = [ module.vpc_us_east_2.alb-subnets[0] ]
    alb-listener = module.alb_us_east_2.listener
    acm_cert_arn = aws_acm_certificate.api["us-east-2"].arn
    acm_cert_val = aws_acm_certificate_validation.api_cert_val_us_east_2
    hosted_zone_zone_id = aws_route53_zone.this.zone_id
    domain_name = var.domain_name
    log_group_arn = module.apigateway_loggroup_us_east_2.log_group_arn
    
    providers = {
        aws = aws.ue2
    }
}

module "api_gateway_eu_west_1" {
    source = "./modules/api-gateway"

    vpc-link-sg = module.vpc_eu_west_1.vpc-link-sg
    alb-subnets = [ module.vpc_eu_west_1.alb-subnets[0] ]
    alb-listener = module.alb_eu_west_1.listener
    acm_cert_arn = aws_acm_certificate.api["eu-west-1"].arn
    acm_cert_val = aws_acm_certificate_validation.api_cert_val_eu_west_1
    hosted_zone_zone_id = aws_route53_zone.this.zone_id
    domain_name = var.domain_name
    log_group_arn = module.apigateway_loggroup_eu_west_1.log_group_arn
    
    providers = {
        aws = aws.ew1
    }
}

module "sigv4a" {
    source = "./modules/sigv4a"

    providers = {
        aws = aws.ue1
    }

    mrap_arn = aws_s3control_multi_region_access_point.staticpage.arn
    bucket_lambda_bucket = module.bucket_lambda.bucket
    bucket_lambda_id = module.bucket_lambda.bucket_id
    bucket_staticweb_arns = [ for item in module.bucket_staticweb : item.bucket_arn ]
    dlq_arn = module.regional_us_east_2.error_dlq_arn
}

module "cloudfront" {
    source = "./modules/cloudfront"
    mrap_domain_name = aws_s3control_multi_region_access_point.staticpage.domain_name
    acm_cert_arn = aws_acm_certificate.us_east_1.arn
    acm_cert_validation = aws_acm_certificate_validation.us_east_1
    hosted_zone_zone_id = aws_route53_zone.this.zone_id
    domain_name = var.domain_name
    access_logs_bucket_domain_name = module.bucket_access_logs["us-east-1"].bucket_domain_name
}
