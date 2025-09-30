terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_lb_target_group" "propiedades" {
    vpc_id      = var.vpc-id
    name        = "propiedades-tg"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
}

resource "aws_lb" "this" {
    name               = "main-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [ var.alb-sg-id ]
    subnets            = [ for subnet in var.alb-subnet : subnet.id ]
   ip_address_type = "ipv4"

    tags = {
        Name = "main-alb"
    }
}

resource "aws_lb_listener" "propiedades" {
    load_balancer_arn = aws_lb.this.arn
    port              = 80
    protocol = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.propiedades.arn
    }
}