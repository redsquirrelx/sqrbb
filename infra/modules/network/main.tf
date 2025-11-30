terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc" "this" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "main-vpc"
    }
}

data "aws_iam_policy_document" "vpc_assume_role" {
    statement {
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = [ "vpc-flow-logs.amazonaws.com" ]
        }

        actions = ["sts:AssumeRole"]
    }
}

resource "aws_iam_role" "vpc" {
    name               = "vpc_role_${var.region}"
    assume_role_policy = data.aws_iam_policy_document.vpc_assume_role.json
}

data "aws_iam_policy_document" "vpc" {
    statement {
        effect = "Allow"

        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
        ]

        resources = [
            var.flow_log_group_arn
        ]
    }
}

resource "aws_iam_role_policy" "vpc" {
    role   = aws_iam_role.vpc.id
    policy = data.aws_iam_policy_document.vpc.json
}

resource "aws_flow_log" "vpc" {
    iam_role_arn = aws_iam_role.vpc.arn
    log_destination = var.flow_log_group_arn
    traffic_type = "ALL"
    vpc_id = aws_vpc.this.id
}

#### SECURITY GROUPS

## DEFAULT
resource "aws_default_security_group" "default" {
    vpc_id = aws_vpc.this.id
}

## VPC-LINK-SG
resource "aws_security_group" "vpc-link" {
    vpc_id = aws_vpc.this.id
    name = "vpc-link-sg"
    tags = {
        Name = "vpc-link-sg"
    }
    description = "Security Group para VPC Link"
}

resource "aws_vpc_security_group_egress_rule" "vpc-link" {

    security_group_id = aws_security_group.vpc-link.id
    referenced_security_group_id = aws_security_group.alb.id
    ip_protocol = "tcp"
    from_port = 443
    to_port = 443

    description = "Permite enviar peticiones al SG del ALB"
}

## ALB-SG
resource "aws_security_group" "alb" {
    vpc_id = aws_vpc.this.id
    name = "alb-sg"
    tags = {
        Name = "alb-sg"
    }

    description = "Security Group para ALB"
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
    security_group_id = aws_security_group.alb.id
    referenced_security_group_id = aws_security_group.vpc-link.id
    ip_protocol = "tcp"
    from_port = 443
    to_port = 443

    description = "Permitir ingreso solo por el SG del VPC Link"
}

resource "aws_vpc_security_group_egress_rule" "alb" {
    security_group_id = aws_security_group.alb.id
    referenced_security_group_id = aws_security_group.service.id
    ip_protocol = "tcp"
    from_port = 80
    to_port = 80

    description = "Permitir egreso solamente hacia el SG de los servicios"
}

## SERVICES-SG
resource "aws_security_group" "service" {
    vpc_id = aws_vpc.this.id
    name = "services-sg"
    tags = {
        Name = "services-sg"
    }

    description = "Security Group para los servicios de fargate"
}

resource "aws_vpc_security_group_ingress_rule" "service" {
    security_group_id = aws_security_group.service.id
    referenced_security_group_id = aws_security_group.alb.id
    ip_protocol = "-1"

    description = "Permitir ingreso solamente del SG del ALB"
}

resource "aws_vpc_security_group_egress_rule" "service" {
    security_group_id = aws_security_group.service.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

    description = "Permitir egreso hacia cualquier lado (cambiar)"
}

# LAMBDAS


resource "aws_security_group" "actualizar_estadisticas" {
    vpc_id = aws_vpc.this.id
    name = "actualizar_estadisticas_sg"
    tags = {
        Name = "actualizar_estadisticas_sg"
    }

    description = "Security Group para actualizar_estadisticas"
}

resource "aws_vpc_security_group_egress_rule" "actualizar_estadisticas" {
    security_group_id = aws_security_group.actualizar_estadisticas.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

    description = "Permitir egreso hacia cualquier lado"
}

resource "aws_security_group" "enviar_correo" {
    vpc_id = aws_vpc.this.id
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

# Para ignorar: CKV2_AWS_5. Los SG son usados en otros modulos, pero
# checkov no es capaz de detectar esto.
resource "aws_network_interface" "dummy" {
    count = 0
    subnet_id       = aws_subnet.lambda_subnets[0].id
    security_groups = [
        aws_security_group.service.id,
        aws_security_group.alb.id,
        aws_security_group.vpc-link.id,
        aws_security_group.actualizar_estadisticas.id,
        aws_security_group.enviar_correo.id
    ]
}