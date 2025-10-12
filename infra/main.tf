module "vpc-us-east-2" {
    source = "./modules/network"
    providers = {
        aws = aws.ue2
    }
}

module "vpc-sa-east-1" {
    source = "./modules/network"
    providers = {
        aws = aws.se1
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

module "services" {
    source = "./modules/services"
    vpc-id = module.vpc-us-east-2.vpc-id
    service-sg = module.vpc-us-east-2.service-sg
    service-subnets = module.vpc-us-east-2.service-subnets
    propiedades-tg = module.alb.propiedades-tg
    reservas-tg = module.alb.reservas-tg

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
        aws = aws.ue2
    }
}

data "aws_caller_identity" "current" { }