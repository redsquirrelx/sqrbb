terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
   name = "ecs_task_execution_${var.region}"
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
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
   name = "ecs_task_role_${var.region}"
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

resource "aws_iam_policy" "this" {
    name = "dynamodb_access_policy_${var.region}" # NOmbre de la politica
    description = "Politicas para acceso a las tablas de DynamoDB"

    policy = var.service_policy_document_json
}

resource "aws_iam_role_policy_attachment" "this" {
    policy_arn = aws_iam_policy.this.arn
    role = aws_iam_role.ecs_task_role.name
}

resource "aws_ecs_task_definition" "this" {
    family = "msrvc-${ var.name }"
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
    container_definitions = var.container_definition_json
}

resource "aws_ecs_service" "this" {
    name            = var.name
    cluster         = var.cluster_id
    task_definition = aws_ecs_task_definition.this.arn
    scheduling_strategy = "REPLICA"
    desired_count   = 2
    availability_zone_rebalancing = "ENABLED"
    launch_type = "FARGATE"

    network_configuration {
        security_groups = [ var.security_group_id ]
        subnets = var.subnets_ids
    }

    load_balancer {
        target_group_arn = var.target_group_arn
        container_name   = var.name
        container_port   = 80
    }

    lifecycle {
        ignore_changes = [ task_definition ]
    }
}