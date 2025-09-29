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

    tags = {
        Name = "main-vpc"
    }
}

#### SECURITY GROUPS

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
    cidr_ipv4 = "0.0.0.0/0"
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

#### SUBNETS

## ALB_SUBNET
resource "aws_subnet" "alb-subnet" {
    vpc_id = aws_vpc.this.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "alb-subnet"
    }
}

## APP_SUBNET
resource "aws_subnet" "app-subnet" {
    vpc_id = aws_vpc.this.id
    cidr_block = "10.0.192.0/20"
    tags = {
        Name = "app-subnet"
    }
}