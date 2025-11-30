module "reservas" {
    source = "../ecs-service"
    
    name = "reservas"

    region = var.region
    service_policy_document_json = data.aws_iam_policy_document.reservas.json
    container_definition_json = local.reservas_container_definition
    cluster_id = aws_ecs_cluster.this.id
    cluster_name = aws_ecs_cluster.this.name

    security_group_id = var.service_data.reservas.security_group_id
    subnets_ids = var.service_data.reservas.subnets_ids
    target_group_arn = var.service_data.reservas.target_group_arn
}

data "aws_iam_policy_document" "reservas"{
    statement {
        sid = "AllowFargateSNSAccess"
        effect = "Allow"
        
        actions = [
            "sns:Publish"
        ]

        resources = [ var.service_data.reservas.topic_arn ]
    }

    statement {
        sid = "AllowFargateKMSAccess"
        effect = "Allow"
        
        actions = [
            "kms:GenerateDataKey",
            "kms:Decrypt"
        ]

        resources = [
            var.service_data.reservas.kms_arn
        ]
    }

    statement {
        sid = "CloudwatchLogGroup"
        effect = "Allow"
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = [
            var.loggroup_arn
        ]
    }
}

locals {
    reservas_container_definition = jsonencode([
        {
            name      = "reservas"
            image     = var.service_data.reservas.repository_url
            cpu       = 1
            memory    = 1024
            essential = true
            portMappings = [
                {
                    containerPort = 80
                    hostPort      = 80
                }
            ]
            readonlyRootFilesystem = true
            environment = [
                {
                    name = "RESERVAS_PROC_SNS_TOPIC_ARN",
                    value = var.service_data.reservas.topic_arn
                },
                {
                    name = "SERVICE_REGION",
                    value = var.region
                },
                {
                    name = "DOMAIN_NAME",
                    value = var.domain_name
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-region = var.region
                    awslogs-group = var.loggroup_name
                    awslogs-stream-prefix = "ecs-propiedades"
                }
            }
        }
    ])
}