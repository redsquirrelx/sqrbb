terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
    name = "apigateway_log_group"
    retention_in_days = 1096
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
}

resource "aws_apigatewayv2_route" "this" {
    api_id    = aws_apigatewayv2_api.this.id
    route_key = "ANY /propiedades"
    target = "integrations/${aws_apigatewayv2_integration.alb.id}"
    authorization_type = "JWT"
}

resource "aws_apigatewayv2_stage" "this" {
    api_id = aws_apigatewayv2_api.this.id
    name   = "$default"
    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.this.arn
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