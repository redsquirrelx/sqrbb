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
    alb-subnet = module.vpc-us-east-2.alb-subnet

    providers = {
      aws = aws.ue2
    }
}

module "services" {
    source = "./modules/services"
    vpc-id = module.vpc-us-east-2.vpc-id
    service-sg = module.vpc-us-east-2.service-sg
    app-subnet = module.vpc-us-east-2.app-subnet
    propiedades-tg = module.alb.propiedades-tg
    reservas-tg = module.alb.reservas-tg

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