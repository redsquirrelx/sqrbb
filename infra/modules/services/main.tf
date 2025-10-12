terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_ecr_repository" "msrvc-reservas" {
  name                 = "msrvc/reservas"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "msrvc-propiedades" {
  name                 = "msrvc/propiedades"
  image_tag_mutability = "MUTABLE"
}

resource "aws_iam_policy" "ecs-task-execution" {
    name        = "ecs-task-execution"
    path        = "/"
    description = "ecs-task-execution"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:BatchGetImage",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role" "ecs-task-execution" {
   name = "ecs-task-execution"
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

resource "aws_iam_role_policy_attachment" "ecs-task-execution" {
    role       = aws_iam_role.ecs-task-execution.name
    policy_arn = aws_iam_policy.ecs-task-execution.arn
}

data "aws_region" "current" {}

resource "aws_ecs_task_definition" "propiedades-td" {
    family = "msrvc-propiedades"
    requires_compatibilities = [ "FARGATE" ]
    cpu = 512
    memory = 1024
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }
    execution_role_arn = aws_iam_role.ecs-task-execution.arn
    network_mode = "awsvpc"
    container_definitions = jsonencode([
        {
            name      = "msrvc-propiedades"
            image     = aws_ecr_repository.msrvc-propiedades.repository_url
            cpu       = 1
            memory    = 1024
            essential = true
            portMappings = [
                {
                    containerPort = 80
                    hostPort      = 80
                }
            ]
        }
    ])
}

resource "aws_ecs_task_definition" "reservas-td" {
    family = "msrvc-reservas"
    requires_compatibilities = [ "FARGATE" ]
    cpu = 512
    memory = 1024
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture = "X86_64"
    }
    execution_role_arn = aws_iam_role.ecs-task-execution.arn
    network_mode = "awsvpc"
    container_definitions = jsonencode([
        {
            name      = "msrvc-reservas"
            image     = aws_ecr_repository.msrvc-reservas.repository_url
            cpu       = 1
            memory    = 1024
            essential = true
            portMappings = [
                {
                    containerPort = 80
                    hostPort      = 80
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

resource "aws_ecs_service" "propiedades" {
    name            = "propiedades-srvc"
    cluster         = aws_ecs_cluster.this.id
    task_definition = aws_ecs_task_definition.propiedades-td.arn
    scheduling_strategy = "REPLICA"
    desired_count   = 2
    availability_zone_rebalancing = "ENABLED"
    launch_type = "FARGATE"

    network_configuration {
        security_groups = [ var.service-sg.id ]
        subnets = [for subnet in var.service-subnets : subnet.id ]
    }

    load_balancer {
        target_group_arn = var.propiedades-tg.arn
        container_name   = "msrvc-propiedades"
        container_port   = 80
    }
}

resource "aws_ecs_service" "reservas" {
    name            = "reservas-srvc"
    cluster         = aws_ecs_cluster.this.id
    task_definition = aws_ecs_task_definition.reservas-td.arn
    scheduling_strategy = "REPLICA"
    desired_count   = 2
    availability_zone_rebalancing = "ENABLED"
    launch_type = "FARGATE"

    network_configuration {
        security_groups = [ var.service-sg.id ]
        subnets = [for subnet in var.service-subnets : subnet.id ]
    }

    load_balancer {
        target_group_arn = var.reservas-tg.arn
        container_name   = "msrvc-reservas"
        container_port   = 80
    }
}