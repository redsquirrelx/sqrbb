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

resource "aws_cloudwatch_log_group" "flow_log" {
    name = "flow_log"
    retention_in_days = 365
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
    name               = "vpc_role"
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
            aws_cloudwatch_log_group.flow_log.arn
        ]
    }
}

resource "aws_iam_role_policy" "vpc" {
    role   = aws_iam_role.vpc.id
    policy = data.aws_iam_policy_document.vpc.json
}

resource "aws_flow_log" "vpc" {
    iam_role_arn = aws_iam_role.vpc.arn
    log_destination = aws_cloudwatch_log_group.flow_log.arn
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
# checkov:skip=CKV2_AWS_5:SI existen servicios asociados a este SG (modules/api-gateway)

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
    ip_protocol = "-1"

    description = "Permite enviar peticiones al SG del ALB"
}

## ALB-SG
resource "aws_security_group" "alb" {
# checkov:skip=CKV2_AWS_5:SI existen servicios asociados a este SG (modules/alb)
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
    ip_protocol = "-1"

    description = "Permitir ingreso solo por el SG del VPC Link"
}

resource "aws_vpc_security_group_egress_rule" "alb" {
    security_group_id = aws_security_group.alb.id
    referenced_security_group_id = aws_security_group.service.id
    ip_protocol = "-1"

    description = "Permitir egreso solamente hacia el SG de los servicios"
}

## SERVICES-SG
resource "aws_security_group" "service" {
# checkov:skip=CKV2_AWS_5:SI existen servicios asociados a este SG (modules/services)
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

## ENDPOINTS-SG

resource "aws_security_group" "endpoints" {
    vpc_id = aws_vpc.this.id
    name = "endpoints-sg"
    tags = {
        Name = "endpoints-sg"
    }

    description = "Security Group para los endpoints"
}

resource "aws_vpc_security_group_ingress_rule" "endpoints" {
    security_group_id = aws_security_group.endpoints.id
    referenced_security_group_id = aws_security_group.service.id
    ip_protocol                  = "-1"

    description = "Permitir ingreso solamente del SG de los servicios de fargate"
}

resource "aws_vpc_security_group_egress_rule" "endpoints" {
    security_group_id = aws_security_group.endpoints.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"

    description = "Permitir egreso hacia cualquier lado"
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "ecr_api" {
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
    vpc_endpoint_type = "Interface"
    subnet_ids        = [ aws_subnet.service-subnets[0].id ]
    security_group_ids = [ aws_security_group.endpoints.id ]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
    vpc_endpoint_type = "Interface"
    subnet_ids        = [ aws_subnet.service-subnets[0].id ]
    security_group_ids = [ aws_security_group.endpoints.id ]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids   = [ aws_route_table.service.id ]
}