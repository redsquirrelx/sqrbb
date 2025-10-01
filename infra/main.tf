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
    alb-sg-id = module.vpc-us-east-2.alb-sg-id
    alb-subnet = module.vpc-us-east-2.alb-subnet
    vpc-id = module.vpc-us-east-2.vpc-id

    providers = {
      aws = aws.ue2
    }
}

module "services" {
    source = "./modules/services"
    aws-account-id = var.aws-account-id
    vpc-id = module.vpc-us-east-2.vpc-id
    service-sg-id = module.vpc-us-east-2.services-sg-id
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