module "vpc-us-east-2" {
    source = "./modules/network"
    providers = {
        aws = aws.ue2
    }
}

    flow_log_group_arn = module.vpc_loggroup.log_group_arn

    providers = {
        aws = aws.ue2
    }
}

module "alb" {
    source = "./modules/alb"
    vpc-id = module.vpc-us-east-2.vpc-id
    alb-sg = module.vpc-us-east-2.alb-sg
    alb-subnets = module.vpc-us-east-2.alb-subnets
    access_logs_bucket_id = module.bucket_access_logs["us-east-2"].bucket_id
    acm_cert_arn = aws_acm_certificate.api["us-east-2"].arn
    acm_cert_validation = aws_acm_certificate_validation.api_cert_val

    providers = {
      aws = aws.ue2
    }
}

module "ecr" {
    source = "./modules/ecr"

    providers = {
      aws = aws.ue2
    }
}

# Temporal
locals {
    microservices  = {
        propiedades = {
            name = "propiedades",
            repository_url = module.ecr.msrvc-propiedades-repository.repository_url,
            security_group = module.vpc-us-east-2.service-sg
            subnets = module.vpc-us-east-2.service-subnets
            target_group = module.alb.propiedades-tg
        },
        reservas = {
            name = "reservas",
            repository_url = module.ecr.msrvc-reservas-repository.repository_url,
            security_group = module.vpc-us-east-2.service-sg
            subnets = module.vpc-us-east-2.service-subnets
            target_group = module.alb.reservas-tg
        }
    }
}

module "services" {
    source = "./modules/services"
    vpc-id = module.vpc-us-east-2.vpc-id

    microservices_definition = local.microservices

    providers = {
        aws = aws.ue2
    }
}

module "api-gateway" {
    source = "./modules/api-gateway"

    vpc-link-sg = module.vpc-us-east-2.vpc-link-sg
    alb-subnets = module.vpc-us-east-2.alb-subnets
    alb-listener = module.alb.listener
    acm_cert_arn = aws_acm_certificate.api["us-east-2"].arn
    hosted_zone_zone_id = aws_route53_zone.this.zone_id
    domain_name = var.domain_name
    log_group_arn = module.apigateway_loggroup.log_group_arn
    
    providers = {
        aws = aws.ue2
    }
}

module "frontend" {
    source = "./modules/frontend"
    
    providers = {
        aws.ue1 = aws.ue1
        aws.ue2 = aws.ue2
        aws.se1 = aws.se1
        aws.ew1 = aws.ew1
    }
}

module "lambda" {
    source = "./modules/lambda"

    providers = {
        aws = aws.ue1
    }

    mrap_arn = aws_s3control_multi_region_access_point.staticpage.arn
    bucket_lambda_bucket = module.bucket_lambda.bucket
    bucket_lambda_id = module.bucket_lambda.bucket_id
    bucket_staticweb_arns = [ for item in module.bucket_staticweb : item.bucket_arn ]
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

data "aws_caller_identity" "current" { }