locals {
    logs_regions = {
        us-east-1 = {}
        us-east-2 = {}
        eu-west-1 = {}
    }
}

# Access Logs
module "bucket_access_logs" {
    for_each = local.logs_regions

    source = "./modules/s3bucket"
    bucket_name = "redsqx-access-logs-${each.key}"
    region = each.key
    
    enable_access_logs = false
    replicate = false
    enable_event_notifs = false
}

resource "aws_s3_bucket_ownership_controls" "access_logs_us_east_1" {
# checkov:skip=CKV2_AWS_65:es necesario para el access logging de cloudfront

    bucket = module.bucket_access_logs["us-east-1"].bucket_id
    region = "us-east-1"
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_acl" "access_logs_us_east_1" {
    depends_on = [ aws_s3_bucket_ownership_controls.access_logs_us_east_1 ]
    region = "us-east-1"
    bucket = module.bucket_access_logs["us-east-1"].bucket_id
    acl    = "private"
}

data "aws_iam_policy_document" "alb_access_logs_us_east_2" {
    statement {
        sid = "PermitirALBAccessLog"
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = [ "logdelivery.elasticloadbalancing.amazonaws.com" ]
        }
        actions = [ "s3:PutObject" ]
        resources = [ "${module.bucket_access_logs["us-east-2"].bucket_arn}/AWSLogs/*" ]
    }
}

resource "aws_s3_bucket_policy" "access_logs_us_east_2" {
    region = "us-east-2"
    
    bucket = module.bucket_access_logs["us-east-2"].bucket
    policy = data.aws_iam_policy_document.alb_access_logs_us_east_2.json
}

data "aws_iam_policy_document" "alb_access_logs_eu_west_1" {
    statement {
        sid = "PermitirALBAccessLog"
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = [ "logdelivery.elasticloadbalancing.amazonaws.com" ]
        }
        actions = [ "s3:PutObject" ]
        resources = [
            "${module.bucket_access_logs["eu-west-1"].bucket_arn}/AWSLogs/*"
        ]
    }
}

resource "aws_s3_bucket_policy" "access_logs_eu_west_1" {
    region = "eu-west-1"
    
    bucket = module.bucket_access_logs["eu-west-1"].bucket
    policy = data.aws_iam_policy_document.alb_access_logs_eu_west_1.json
}

# Lambdas
module "bucket_lambda" {
    source = "./modules/s3bucket"
    bucket_name = "redsqx-us-east-1-lambda"
    region      = "us-east-1"
    
    enable_access_logs        = true
    bucket_access_logs_bucket = module.bucket_access_logs["us-east-1"].bucket
    replicate                 = false
    enable_event_notifs       = false
}

module "bucket_lambda_us_east_2" {
    source = "./modules/s3bucket"
    bucket_name = "redsqx-us-east-2-lambda"
    region      = "us-east-2"
    
    enable_access_logs        = true
    bucket_access_logs_bucket = module.bucket_access_logs["us-east-2"].bucket
    replicate                 = false
    enable_event_notifs       = false
}

module "bucket_lambda_eu_west_1" {
    source = "./modules/s3bucket"
    bucket_name = "redsqx-eu-west-1-lambda"
    region      = "eu-west-1"
    
    enable_access_logs        = true
    bucket_access_logs_bucket = module.bucket_access_logs["eu-west-1"].bucket
    replicate                 = false
    enable_event_notifs       = false
}