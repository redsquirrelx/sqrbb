module "vpc_loggroup" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-2"
    name = "vpc-flow-logs"
    kms_arn = aws_kms_key.kms["us-east-2"].arn
}

module "vpc_loggroup_eu_west_1" {
    source = "./modules/cloudwatch_loggroup"
    region = "eu-west-1"
    name = "vpc-flow-logs"
    kms_arn = aws_kms_key.kms["eu-west-1"].arn
}

module "route53_loggroup" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-1"
    name = "route-53"
    kms_arn = aws_kms_key.kms["us-east-1"].arn
}

module "apigateway_loggroup_us_east_2" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-2"
    name = "apigateway"
    kms_arn = aws_kms_key.kms["us-east-2"].arn
}

module "apigateway_loggroup_eu_west_1" {
    source = "./modules/cloudwatch_loggroup"
    region = "eu-west-1"
    name = "apigateway"
    kms_arn = aws_kms_key.kms["eu-west-1"].arn
}

module "ecs_loggroup_us_east_2" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-2"
    name = "ecslogs"
    kms_arn = aws_kms_key.kms["eu-east-2"].arn
}

module "ecs_loggroup_eu_west_1" {
    source = "./modules/cloudwatch_loggroup"
    region = "eu-west-1"
    name = "ecslogs"
    kms_arn = aws_kms_key.kms["eu-west-1"].arn
}