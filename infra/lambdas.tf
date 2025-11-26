data "aws_iam_policy_document" "assume_role" {
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
            aws_dynamodb_table.propiedades.arn
        ]
    }
}

resource "aws_iam_role" "lambda_actualizar_estadisticas" {
    name               = "lambda_actualizar_estadisticas_role"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_actualizar_estadisticas" {
    name = "lambda_actualizar_estadisticas_policy"
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

resource "aws_security_group" "lambda_actualizar_estadisticas" {
    vpc_id = module.vpc-us-east-2.vpc-id
    name = "lambdas-sg"
    description = "Security Group para lambda_actualizar_estadisticas"
}

resource "aws_vpc_security_group_ingress_rule" "lambda_actualizar_estadisticas" {
    security_group_id = aws_security_group.lambda_actualizar_estadisticas.id
    referenced_security_group_id = module.vpc-us-east-2.service-sg.id
    ip_protocol = "-1"

    description = "Permitir ingreso solamente del SG de servicios"
}

resource "aws_vpc_security_group_egress_rule" "service" {
    security_group_id = aws_security_group.lambda_actualizar_estadisticas.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

    description = "Permitir egreso hacia cualquier lado (cambiar)"
}

module "actualizar_estadisticas" {
    source = "./modules/lambdafn"
    region = "us-east-2"
    name = "actualizar_estadisticas"
    subnets_ids = [ module.vpc-us-east-2.lambda_subnets[0].id ]
    security_groups_ids = [ aws_security_group.lambda_actualizar_estadisticas.id ]
    bucket_lambda_bucket = module.bucket_lambda_us_east_2.bucket
    bucket_lambda_id = module.bucket_lambda_us_east_2.bucket_id
    dlq_arn = aws_sqs_queue.error.arn
    iam_role_arn = aws_iam_role.lambda_actualizar_estadisticas.arn
}

resource "aws_lambda_event_source_mapping" "actualizar_estadisticas" {
    event_source_arn  = module.stats_sqs.sqs_arn
    function_name     = module.actualizar_estadisticas.lambda_arn
    batch_size = 10

    scaling_config {
        maximum_concurrency = 100
    }
}

module "actualizar_estadisticas_loggroup" {
    source = "./modules/cloudwatch_loggroup"
    region = "us-east-2"
    name = "/aws/lambda/actualizar_estadisticas"
    kms_arn = aws_kms_key.kms["us-east-2"].arn
}