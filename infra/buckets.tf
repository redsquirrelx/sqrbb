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

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
    region = "us-east-2"
    bucket = module.bucket_access_logs.bucket

    bucket = module.bucket_access_logs["us-east-1"].bucket_id
    region = "us-east-1"
    rule {
        id = "1"
        status = "Enabled"

        filter {
            prefix = "AWSLogs/"
        }

        expiration {
          days = 365
        }
    }

    rule {
        id = "2"
        status = "Enabled"

        filter {}

        abort_incomplete_multipart_upload {
          days_after_initiation = 1
        }
    }
}

data "aws_iam_policy_document" "alb_access_logs" {
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

resource "aws_s3_bucket_policy" "access_logs" {
    region = "us-east-2"
    
    bucket = module.bucket_access_logs["us-east-2"].bucket
    policy = data.aws_iam_policy_document.alb_access_logs.json
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