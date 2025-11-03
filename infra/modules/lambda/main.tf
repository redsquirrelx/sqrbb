terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = [
                "lambda.amazonaws.com",
                "edgelambda.amazonaws.com"
            ]
        }

        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "lambda-sigv4a" {
    name               = "lambda-sigv4a-role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "sigv4a" {
    statement {
        effect = "Allow"
        actions = [
            "s3:GetObject",
            "s3:ListBucket"
        ]
        resources = concat([
                "${var.mrap_arn}/*",
                "${var.mrap_arn}"
            ],
            var.bucket_staticweb_arns,
            [ for i in var.bucket_staticweb_arns : "${i}/*" ]
            
        )
    }

    statement {
        effect = "Allow"
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = [
            "arn:aws:logs:*:*:*"
        ]
    }
}

resource "aws_iam_policy" "sigv4a" {
    name = "sigv4a-lambda-policy"
    policy = data.aws_iam_policy_document.sigv4a.json
}

resource "aws_iam_role_policy_attachment" "sigv4a" {
    policy_arn = aws_iam_policy.sigv4a.arn
    role = aws_iam_role.lambda-sigv4a.name
}

resource "aws_lambda_function" "sigv4a" {
    role = aws_iam_role.lambda-sigv4a.arn
    function_name = "sigv4a"
    runtime = "nodejs22.x"
    handler = "index.handler"

    s3_bucket = var.bucket_lambda_id
    s3_key = aws_signer_signing_job.dummy.signed_object[0].s3[0].key

    code_signing_config_arn = aws_lambda_code_signing_config.sigv4a.arn

    reserved_concurrent_executions = -1

    tracing_config {
        mode = "Active"
    }
}

resource "aws_signer_signing_profile" "test_sp" {
    platform_id = "AWSLambda-SHA384-ECDSA"
}

resource "aws_lambda_code_signing_config" "sigv4a" {
    allowed_publishers {
        signing_profile_version_arns = [ aws_signer_signing_profile.test_sp.version_arn ]
    }

    policies {
        untrusted_artifact_on_deployment = "Enforce"
    }
}

resource "aws_s3_object" "dummy" {
    bucket = var.bucket_lambda_bucket
    key    = "sigv4a/func.zip"
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
    key = "sigv4a/func.zip"
    depends_on = [ aws_s3_object.dummy ]
}

resource "aws_signer_signing_job" "dummy" {
    profile_name = aws_signer_signing_profile.test_sp.name
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
            prefix = "sigv4a/signed-"
        }
    }

    lifecycle {
        ignore_changes = [ 
            source[0]
         ]
    }
}