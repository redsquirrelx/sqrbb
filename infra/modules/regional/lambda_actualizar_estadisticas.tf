data "aws_iam_policy_document" "lambda_actualizar_estadisticas_assume_role" {
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

data "aws_iam_policy_document" "lambda_actualizar_estadisticas" {
    statement {
        effect = "Allow"
        sid = "SQSAccess"
        actions = [
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
        ]
        resources = [
            module.stats_sqs.sqs_arn
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
        sid = "DynamoDBAccess"
        actions = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query", #Para consultar usando la llave primaria
            "dynamodb:Scan" # Escanear toda la tabla (COstoso)
        ]
        resources = [
            var.dynamodb_propiedades_arn
        ]
    }
}

resource "aws_iam_role" "lambda_actualizar_estadisticas" {
    name               = "lambda_actualizar_estadisticas_role_${var.region}"
    assume_role_policy = data.aws_iam_policy_document.lambda_actualizar_estadisticas_assume_role.json
}

resource "aws_iam_policy" "lambda_actualizar_estadisticas" {
    name = "lambda_actualizar_estadisticas_policy_${var.region}"
    policy = data.aws_iam_policy_document.lambda_actualizar_estadisticas.json
}

resource "aws_iam_role_policy_attachment" "lambda_actualizar_estadisticas_pol_a" {
    policy_arn = aws_iam_policy.lambda_actualizar_estadisticas.arn
    role = aws_iam_role.lambda_actualizar_estadisticas.name
}

resource "aws_iam_role_policy_attachment" "lambda_actualizar_estadisticas_pol_b" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
    role = aws_iam_role.lambda_actualizar_estadisticas.name
}

resource "aws_security_group" "actualizar_estadisticas" {
    region = var.region
    vpc_id = var.vpc_id
    name = "actualizar_estadisticas_sg"
    tags = {
        Name = "actualizar_estadisticas_sg"
    }

    description = "Security Group para actualizar_estadisticas"
}

resource "aws_vpc_security_group_egress_rule" "actualizar_estadisticas" {
    region = var.region
    security_group_id = aws_security_group.actualizar_estadisticas.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

    description = "Permitir egreso hacia cualquier lado"
}

module "actualizar_estadisticas" {
    source = "../lambdafn"
    region = var.region
    name = "actualizar_estadisticas"
    subnets_ids = [ var.lambda_subnets[0].id ]
    security_groups_ids = [ aws_security_group.actualizar_estadisticas.id ]
    bucket_lambda_bucket = var.lambda_bucket_bucket
    bucket_lambda_id = var.lambda_bucket_id
    dlq_arn = aws_sqs_queue.error.arn
    iam_role_arn = aws_iam_role.lambda_actualizar_estadisticas.arn
    kms_key_arn = var.lambda_kms_key_arn
    env_variables = {
        REGION = var.region
    }
}

resource "aws_lambda_event_source_mapping" "actualizar_estadisticas" {
    region = var.region
    event_source_arn  = module.stats_sqs.sqs_arn
    function_name     = module.actualizar_estadisticas.lambda_arn
    batch_size = 10

    scaling_config {
        maximum_concurrency = 100
    }
}

module "actualizar_estadisticas_loggroup" {
    source = "../cloudwatch_loggroup"
    region = var.region
    name = "/aws/lambda/actualizar_estadisticas"
    kms_arn = var.kms_arn
}