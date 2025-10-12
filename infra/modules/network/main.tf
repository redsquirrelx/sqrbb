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

#### SECURITY GROUPS

## VPC-LINK-SG
resource "aws_security_group" "vpc-link" {
    vpc_id = aws_vpc.this.id
    name = "vpc-link-sg"
    tags = {
        Name = "vpc-link-sg"
    }
}

resource "aws_vpc_security_group_egress_rule" "vpc-link" {
    security_group_id = aws_security_group.vpc-link.id
    referenced_security_group_id = aws_security_group.alb-sg.id
    ip_protocol = "-1"
}

## ALB-SG
resource "aws_security_group" "alb-sg" {
    vpc_id = aws_vpc.this.id
    name = "alb-sg"
    tags = {
        Name = "alb-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "alb-sg-ingress" {
    security_group_id = aws_security_group.alb-sg.id
    referenced_security_group_id = aws_security_group.vpc-link.id
    ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "alb-sg-egress" {
    security_group_id = aws_security_group.alb-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

## SERVICES-SG
resource "aws_security_group" "services-sg" {
    vpc_id = aws_vpc.this.id
    name = "services-sg"
    tags = {
        Name = "services-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "services-sg-ingress" {
   security_group_id = aws_security_group.services-sg.id
   referenced_security_group_id = aws_security_group.alb-sg.id
   ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "services-sg-egress" {
    security_group_id = aws_security_group.services-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_security_group" "endpoints" {
    vpc_id = aws_vpc.this.id
    name = "endpoints-sg"
    tags = {
        Name = "endpoints-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "endpoints" {
   security_group_id = aws_security_group.endpoints.id
    referenced_security_group_id = aws_security_group.services-sg.id
    ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "endpoints" {
    security_group_id = aws_security_group.endpoints.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

data "aws_region" "current" {}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [ for subnet in aws_subnet.app-subnet: subnet.id ]
  security_group_ids = [ aws_security_group.endpoints.id ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [ for subnet in aws_subnet.app-subnet: subnet.id ]
  security_group_ids = [ aws_security_group.endpoints.id ]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [ aws_route_table.app-subnet-rt.id ]
}