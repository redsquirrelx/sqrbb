terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
    name               = "vpc-link-for-alb"
    security_group_ids = [ var.vpc-link-sg.id ]
    subnet_ids         = [ for subnet in var.alb-subnets : subnet.id ]

    tags = {
        Usage = "para internal alb"
    }
}

resource "aws_apigatewayv2_api" "this" {
    name          = "http-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "alb" {
    api_id           = aws_apigatewayv2_api.this.id
    description      = "integración alb"
    integration_type = "HTTP_PROXY"
    integration_uri  = var.alb-listener.arn

    integration_method = "ANY"
    connection_type    = "VPC_LINK"
    connection_id      = aws_apigatewayv2_vpc_link.this.id

    tls_config {
        server_name_to_verify = "api.${ var.domain_name }"
    }
}

resource "aws_apigatewayv2_route" "this" {
    api_id    = aws_apigatewayv2_api.this.id
    route_key = "ANY /{proxy+}"
    target = "integrations/${aws_apigatewayv2_integration.alb.id}"
}

resource "aws_apigatewayv2_stage" "this" {
    api_id = aws_apigatewayv2_api.this.id
    name   = "$default"
    auto_deploy = true
    access_log_settings {
        destination_arn = var.log_group_arn
        format = jsonencode({
            requestId = "$context.requestId"
            extendedRequestId = "$context.extendedRequestId"
            ip = "$context.identity.sourceIp"
            caller = "$context.identity.caller"
            user = "$context.identity.user"
            requestTime = "$context.requestTime"
            httpMethod = "$context.httpMethod"
            resourcePath = "$context.resourcePath"
            status = "$context.status"
            protocol = "$context.protocol"
            responseLength = "$context.responseLength"
        })
    }
}

resource "aws_apigatewayv2_domain_name" "this" {
    domain_name = "api.${var.domain_name}"

    domain_name_configuration {
        certificate_arn = var.acm_cert_arn
        endpoint_type   = "REGIONAL"
        security_policy = "TLS_1_2"
    }

    depends_on = [ var.acm_cert_val ]
}

resource "aws_apigatewayv2_api_mapping" "api" {
    api_id = aws_apigatewayv2_api.this.id
    domain_name = aws_apigatewayv2_domain_name.this.domain_name
    stage = aws_apigatewayv2_stage.this.id
}

resource "aws_route53_record" "api" {
    zone_id = var.hosted_zone_zone_id
    name    = aws_apigatewayv2_domain_name.this.domain_name
    type    = "A"

    alias {
        name = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].target_domain_name
        zone_id = aws_apigatewayv2_domain_name.this.domain_name_configuration[0].hosted_zone_id
        evaluate_target_health = true
    }
}