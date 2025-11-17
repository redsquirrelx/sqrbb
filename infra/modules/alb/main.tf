terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_lb_target_group" "propiedades" {
# checkov:skip=CKV_AWS_378:no manejamos cifrado interno
    vpc_id      = var.vpc-id
    name        = "propiedades-tg"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"

    health_check {
        enabled = true
        healthy_threshold = 3
        unhealthy_threshold = 3
        path = "/propiedades"
        port = 80
        protocol = "HTTP"
        timeout = 5
        matcher = "200"
    }
}

resource "aws_lb_target_group" "reservas" {
    vpc_id      = var.vpc-id
    name        = "reservas-tg"
    port        = 80
    protocol    = "HTTP"
    target_type = "ip"
    
    health_check {
        enabled = true
        healthy_threshold = 3
        unhealthy_threshold = 3
        path = "/reservas"
        port = 80
        protocol = "HTTP"
        timeout = 5
        matcher = "200"
    }
}

resource "aws_lb" "this" {
    name               = "main-alb"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [ var.alb-sg.id ]
    subnets            = [ for subnet in var.alb-subnets : subnet.id ]
    ip_address_type = "ipv4"

    enable_deletion_protection = true
    drop_invalid_header_fields = true

    access_logs {
        enabled = true
        bucket = var.access_logs_bucket_id
    }

    tags = {
        Name = "main-alb"
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port        = 80
    protocol    = "HTTP"

    default_action {
        type = "redirect"

        redirect {
            protocol = "HTTPS"
            port = "443"
            status_code = "HTTP_301"
        }
    }
}

resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.this.arn
    port        = 443
    protocol    = "HTTPS"
    certificate_arn = var.acm_cert_arn

    ssl_policy = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            status_code  = "404"
        }
    }

    depends_on = [ var.acm_cert_validation ]
}

resource "aws_lb_listener_rule" "propiedades" {
    listener_arn = aws_lb_listener.this.arn
    priority     = 1

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.propiedades.arn
    }

    condition {
        path_pattern {
            values = [
                "/propiedades",
                "/propiedades/*"
            ]
        }
    }
}

resource "aws_lb_listener_rule" "reservas" {
    listener_arn = aws_lb_listener.this.arn
    priority     = 2

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.reservas.arn
    }

    condition {
        path_pattern {
            values = [
                "/propiedades",
                "/propiedades/*"
            ]
        }
    }
}