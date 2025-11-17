module "vpc_loggroup" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-2"
    name = "vpc-flow-logs"
    kms_arn = aws_kms_key.kms["us-east-2"].arn
}

module "route53_loggroup" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-1"
    name = "route-53"
    kms_arn = aws_kms_key.kms["us-east-1"].arn
}