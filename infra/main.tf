module "vpc-us-east-2" {
    source = "./modules/network"
    providers = {
        aws = aws.ue2
    }
}

module "alb" {
    source = "./modules/alb"
    vpc-id = module.vpc-us-east-2.vpc-id
    alb-sg = module.vpc-us-east-2.alb-sg
    alb-subnets = module.vpc-us-east-2.alb-subnets

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

    mrap = module.frontend.mrap
}

module "cloudfront" {
    source = "./modules/cloudfront"
    mrap = module.frontend.mrap
    sigv4a-lmbd-fn = module.lambda.lambda-fn-sigv4a
}

data "aws_caller_identity" "current" { }