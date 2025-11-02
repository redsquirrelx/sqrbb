resource "aws_route53_zone" "this" {
    provider = aws.ue1
    
    name = var.domain_name
}

resource "aws_route53_query_log" "route53" {
    provider = aws.ue1

    depends_on               = [ aws_cloudwatch_log_resource_policy.route53_query_logging ]
    zone_id                  = aws_route53_zone.this.id
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53.arn
}

resource "aws_cloudwatch_log_group" "route53" {
    provider = aws.ue1

    name = "route53-logs"
    retention_in_days = 365
}

data "aws_iam_policy_document" "route53_query_logging" {
    provider = aws.ue1
    
    statement {
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
        ]

        resources = [
            "${aws_cloudwatch_log_group.route53.arn}:*"
        ]

        principals {
            identifiers = ["route53.amazonaws.com"]
            type        = "Service"
        }
    }
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging" {
    provider = aws.ue1

    policy_document = data.aws_iam_policy_document.route53_query_logging.json
    policy_name     = "route53-query-logging"
}

# Actualizar dominio registrado con los nuevos NS
resource "aws_route53domains_registered_domain" "this" {
    provider = aws.ue1

    domain_name = var.domain_name

    dynamic "name_server" {
        for_each = toset(aws_route53_zone.this.name_servers)
        content {
            name = name_server.value
        }
    }

    transfer_lock = false
    auto_renew    = false
}