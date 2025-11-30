module "propiedades" {
    source = "../ecs-service"

    name = "propiedades"

    region = var.region
    service_policy_document_json = data.aws_iam_policy_document.propiedades.json
    container_definition_json = local.propiedades_container_definition
    cluster_id = aws_ecs_cluster.this.id
    cluster_name = aws_ecs_cluster.this.name

    security_group_id = var.service_data.propiedades.security_group_id
    subnets_ids = var.service_data.propiedades.subnets_ids
    target_group_arn = var.service_data.propiedades.target_group_arn
}

data "aws_iam_policy_document" "propiedades"{
    statement {
        sid = "AllowFargateDynamoDBAccess"
        effect = "Allow"

        # Acciones de un microservicio CRUD
        actions = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query", #Para consultar usando la llave primaria
            "dynamodb:Scan" # Escanear toda la tabla (COstoso)
        ]

        # Recurso sobre el cual se aplica estas acciones
        # Aca se coloca los ARNs
        resources = [ 
            "arn:aws:dynamodb:${var.region}:${var.account_id}:table/Propiedades"
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
    propiedades_container_definition = jsonencode([
                {
            name      = "propiedades"
            image     = var.service_data.propiedades.repository_url
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