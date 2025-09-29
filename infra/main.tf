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

module "s3" {
    source = "./modules/s3"
    providers = {
        aws.ue2 = aws.ue2
        aws.se1 = aws.se1
    }
}