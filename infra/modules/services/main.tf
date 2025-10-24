terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
    name        = "ecs_task_execution"
    description = "ecs_task_execution"
    path        = "/"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
    role       = aws_iam_role.ecs_task_execution.name
    policy_arn = aws_iam_policy.ecs_task_execution.arn
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
}