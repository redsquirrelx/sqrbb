terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
   name = "ecs_task_execution"
   assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
           {
               Action = "sts:AssumeRole"
               Effect = "Allow"
               Sid    = "AllowAccessToECSForTaskExecutionRole"
               Principal = {
                   Service = "ecs-tasks.amazonaws.com"
               }
           },
       ]
   })
}

resource "aws_iam_role" "ecs_task_role" {
   name = "ecs_task_role"
   assume_role_policy = jsonencode({
       Version = "2012-10-17"
       Statement = [
           {
               Action = "sts:AssumeRole"
               Effect = "Allow"
               Sid    = "AllowECSTasksToAssumeRole"
               Principal = {
                   Service = "ecs-tasks.amazonaws.com"
               }
           },
       ]
   })
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
    policy_arn = aws_iam_policy.dynamodb_policy.arn
    role = aws_iam_role.ecs_task_role.name
}

data "aws_iam_policy_document" "dynamodb_access_policy"{
    statement {
        sid = "AllowFargateDynamoDBAccess"
        effect = "Allow"

        # Acciones de un microservicio CRUD
        actions = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:Query", #Para consultar usando la llave primaria
            "dynamodb:Scan" # Escanear toda la tabla (COstoso)
        ]

        # Recurso sobre el cual se aplica estas acciones
        # Aca se coloca los ARNs
        resources = [ 
            var.propiedades_db_arn,
            var.reservas_db_arn
        ]
    }

    statement {
        sid = "AllowFargateSNSAccess"
        effect = "Allow"
        
        actions = [
            "sns:Publish"
        ]

        resources = [ var.reservas_proc_topic_arn ]
    }

    statement {
        sid = "AllowFargateKMSAccess"
        effect = "Allow"
        
        actions = [
            "kms:GenerateDataKey",
            "kms:Decrypt"
        ]

        resources = [
            var.kms_arn
        ]
    }
}

resource "aws_iam_policy" "dynamodb_policy" {
    name = "dynamodb_access_policy" # NOmbre de la politica
    description = "Politicas para acceso a las tablas de DynamoDB"

    # Aca se asigna el JSON que se genero con data source
    policy = data.aws_iam_policy_document.dynamodb_access_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
    role       = aws_iam_role.ecs_task_execution.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "this" {
    for_each = var.microservices_definition

    family = "msrvc-${ each.value.name }"
    requires_compatibilities = [ "FARGATE" ]
    cpu = 512
    memory = 1024
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }

    task_role_arn = aws_iam_role.ecs_task_role.arn
    execution_role_arn = aws_iam_role.ecs_task_execution.arn
    network_mode = "awsvpc"
    container_definitions = jsonencode([
        {
            name      = "msrvc-${ each.value.name }"
            image     = each.value.repository_url
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
                    value = var.reservas_proc_topic_arn
                },
                {
                    name = "SERVICE_REGION",
                    value = "us-east-2"
                }
            ]
        }
    ])
}

resource "aws_ecs_cluster" "this" {
    name = "main-cluster"

    setting {
        name  = "containerInsights"
        value = "enabled"
    }
}

resource "aws_ecs_service" "this" {
    for_each = var.microservices_definition

    name            = "${each.value.name}-srvc"
    cluster         = aws_ecs_cluster.this.id
    task_definition = aws_ecs_task_definition.this[each.value.name].arn
    scheduling_strategy = "REPLICA"
    desired_count   = 2
    availability_zone_rebalancing = "ENABLED"
    launch_type = "FARGATE"

    network_configuration {
        security_groups = [ each.value.security_group.id ]
        subnets = [for subnet in each.value.subnets : subnet.id ]
    }

    load_balancer {
        target_group_arn = each.value.target_group.arn
        container_name   = "msrvc-${each.value.name}"
        container_port   = 80
    }

    lifecycle {
        ignore_changes = [ task_definition ]
    }
}