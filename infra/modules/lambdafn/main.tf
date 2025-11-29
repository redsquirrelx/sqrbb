terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

resource "aws_lambda_function" "this" {
    region = var.region
    vpc_config {
        subnet_ids = var.subnets_ids
        security_group_ids = var.security_groups_ids
    }
    
    role = var.iam_role_arn
    function_name = var.name
    runtime = "nodejs22.x"
    handler = "index.handler"

    s3_bucket = var.bucket_lambda_id
    s3_key = aws_signer_signing_job.dummy.signed_object[0].s3[0].key

    code_signing_config_arn = aws_lambda_code_signing_config.this.arn

    reserved_concurrent_executions = -1

    environment {
        variables = var.env_variables
    }

    kms_key_arn = var.kms_key_arn

    dead_letter_config {
        target_arn = var.dlq_arn
    }

    tracing_config {
        mode = "Active"
    }
}

resource "aws_signer_signing_profile" "this" {
    platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "this" {
    allowed_publishers {
        signing_profile_version_arns = [ aws_signer_signing_profile.this.version_arn ]
    }

    policies {
        untrusted_artifact_on_deployment = "Enforce"
    }
}

resource "aws_s3_object" "dummy" {
    bucket = var.bucket_lambda_bucket
    key    = "lambda/${var.name}/func.zip"
    source = "${path.module}/dummy/function.zip"

    etag = filemd5("${path.module}/dummy/function.zip")

    lifecycle {
        ignore_changes = [ 
            etag
        ]
    }
}

data "aws_s3_object" "dummy" {
    bucket = var.bucket_lambda_bucket
    key = "lambda/${var.name}/func.zip"
    depends_on = [ aws_s3_object.dummy ]
}

resource "aws_signer_signing_job" "dummy" {
    profile_name = aws_signer_signing_profile.this.name
    source {
        s3 {
            bucket = var.bucket_lambda_bucket
            key = data.aws_s3_object.dummy.key
            version = data.aws_s3_object.dummy.version_id
        }
    }
    destination {
        s3 {
            bucket = var.bucket_lambda_bucket
            prefix = "lambda/${var.name}/signed-"
        }
    }

    lifecycle {
        ignore_changes = [ 
            source[0]
         ]
    }
}