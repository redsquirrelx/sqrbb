# Access Logs
module "bucket_access_logs" {
    source = "./modules/s3bucket"
    bucket_name = "redsqx-access-logs"
    region = "us-east-2"
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
    region = "us-east-2"
    bucket = module.bucket_access_logs.bucket

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
        resources = [ "${module.bucket_access_logs.bucket_arn}/AWSLogs/*" ]
    }
}

resource "aws_s3_bucket_policy" "access_logs" {
    region = "us-east-2"
    
    bucket = module.bucket_access_logs.bucket
    policy = data.aws_iam_policy_document.alb_access_logs.json
}

# Lambdas
module "bucket_lambda" {
    source = "./modules/s3bucket"
    bucket_name = "redsqx-us-east-1-lambda"
    region = "us-east-1"
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda" {
    region = "us-east-1"
    
    bucket = module.bucket_lambda.bucket

    rule {
        id = "1"
        status = "Enabled"

        filter {}

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