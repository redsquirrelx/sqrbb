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
            "s3:GetObject"
        ]
        resources = [
            "arn:aws:s3:::redsqx-eu-west-1-web-dist/*",
            "arn:aws:s3:::redsqx-sa-east-1-web-dist/*",
            "arn:aws:s3:::redsqx-us-east-2-web-dist/*",
            "${var.mrap.arn}/*"
        ]
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

    filename = "${path.module}/dummy/function.zip"
    source_code_hash = filemd5("${path.module}/dummy/function.zip")
}