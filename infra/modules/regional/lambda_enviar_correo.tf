data "aws_iam_policy_document" "lambda_enviar_correo_assume_role" {
    statement {
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = [
                "lambda.amazonaws.com"
            ]
        }

        actions = ["sts:AssumeRole"]
    }
}

data "aws_iam_policy_document" "lambda_enviar_correo" {
    statement {
        effect = "Allow"
        sid = "SQSAccess"
        actions = [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
        ]
        resources = [
            module.reserva_mail_sqs.sqs_arn
        ]
    }

    statement {
        effect = "Allow"
        sid = "DLQAccess"
        actions = [
            "sqs:SendMessage"
        ]
        resources = [
            aws_sqs_queue.error.arn
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
    
    statement {
        effect = "Allow"
        sid = "SESAccess"
        actions = [
            "ses:SendEmail",
            "ses:SendRawEmail",
            "ses:SendTemplatedEmail",
            "ses:ListIdentities"
        ]
        resources = [
            "arn:aws:ses:${var.region}:${var.account_id}:identity/*"
        ]
    }
}

resource "aws_iam_role" "lambda_enviar_correo" {
    name               = "lambda_enviar_correo_role"
    assume_role_policy = data.aws_iam_policy_document.lambda_enviar_correo_assume_role.json
}

resource "aws_iam_policy" "lambda_enviar_correo" {
    name = "lambda_enviar_correo_policy"
    policy = data.aws_iam_policy_document.lambda_enviar_correo.json
}

resource "aws_iam_role_policy_attachment" "lambda_enviar_correo_pol_a" {
    policy_arn = aws_iam_policy.lambda_enviar_correo.arn
    role = aws_iam_role.lambda_enviar_correo.name
}

resource "aws_iam_role_policy_attachment" "lambda_enviar_correo_pol_b" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
    role = aws_iam_role.lambda_enviar_correo.name
}

resource "aws_security_group" "enviar_correo" {
    vpc_id = var.vpc_id
    name = "enviar_correo_sg"
    tags = {
        Name = "enviar_correo_sg"
    }

    description = "Security Group para enviar_correo_sg"
}

resource "aws_vpc_security_group_egress_rule" "enviar_correo" {
    security_group_id = aws_security_group.enviar_correo.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

    description = "Permitir egreso hacia cualquier lado"
}

module "enviar_correo" {
    source = "../lambdafn"
    region = var.region
    name = "enviar_correo"
    subnets_ids = [ var.lambda_subnets[0].id ]
    security_groups_ids = [ aws_security_group.enviar_correo.id ]
    bucket_lambda_bucket = var.lambda_bucket_bucket
    bucket_lambda_id = var.lambda_bucket_id
    dlq_arn = aws_sqs_queue.error.arn
    iam_role_arn = aws_iam_role.lambda_enviar_correo.arn
    kms_key_arn = var.lambda_kms_key_arn
    env_variables = {
        REGION = var.region
        SES_SENDER_EMAIL = "support@${aws_ses_domain_mail_from.this.domain}"
    }
}

resource "aws_lambda_event_source_mapping" "enviar_correo" {
    event_source_arn  = module.reserva_mail_sqs.sqs_arn
    function_name     = module.enviar_correo.lambda_arn
    batch_size = 10

    scaling_config {
        maximum_concurrency = 100
    }
}

module "enviar_correo_loggroup" {
    source = "../cloudwatch_loggroup"
    region = var.region
    name = "/aws/lambda/enviar_correo"
    kms_arn = var.kms_arn
}