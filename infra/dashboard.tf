resource "aws_cloudwatch_dashboard" "this" {
    region = "us-east-2"
    dashboard_name = "panel"

    dashboard_body = <<EOF
{
    "widgets": [
        {
            "type": "metric",
            "x": 0,
            "y": 8,
            "width": 6,
            "height": 7,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "propiedades", "ClusterName", "main-cluster", { "region": "us-east-2" } ],
                    [ ".", "MemoryUtilization", ".", ".", ".", ".", { "region": "us-east-2" } ]
                ],
                "region": "us-east-2",
                "title": "Propiedades us-east-2",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "Límite",
                            "value": 70
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 8,
            "width": 6,
            "height": 7,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "reservas", "ClusterName", "main-cluster", { "region": "us-east-2" } ],
                    [ ".", "MemoryUtilization", ".", ".", ".", ".", { "region": "us-east-2" } ]
                ],
                "region": "us-east-2",
                "title": "Reservas us-east-2",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "Untitled annotation",
                            "value": 70
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 1,
            "width": 8,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "5xx", "Stage", "$default", "ApiId", "${module.api_gateway_us_east_2.apigateway_id}", { "region": "us-east-2", "label": "us-east-2" } ],
                    [ "...", "${module.api_gateway_us_east_2.apigateway_id}", { "region": "eu-west-1", "label": "eu-west-1" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "us-east-2",
                "title": "Errores de Servicio no Disponible (5xx)",
                "period": 300,
                "stat": "Average"
            }
        },
        {
            "type": "metric",
            "x": 8,
            "y": 1,
            "width": 8,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "Count", "Stage", "$default", "ApiId", "${module.api_gateway_eu_west_1.apigateway_id}", { "region": "us-east-2", "label": "us-east-2" } ],
                    [ "...", "${module.api_gateway_eu_west_1.apigateway_id}", { "region": "eu-west-1", "label": "eu-west-1" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-2",
                "period": 300,
                "stat": "Average",
                "title": "Uso del servicio (Llamadas a la API)"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 7,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "# Servicios"
            }
        },
        {
            "type": "metric",
            "x": 16,
            "y": 1,
            "width": 8,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/CloudFront", "Requests", "Region", "Global", "DistributionId", "${module.cloudfront.cloudfront-dist-id}", { "region": "us-east-1" } ]
                ],
                "sparkline": true,
                "view": "singleValue",
                "region": "us-east-2",
                "title": "Visitas a la web",
                "period": 300,
                "stat": "Sum"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 8,
            "width": 6,
            "height": 7,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "propiedades", "ClusterName", "main-cluster", { "region": "eu-west-1" } ],
                    [ ".", "MemoryUtilization", ".", ".", ".", ".", { "region": "eu-west-1" } ]
                ],
                "region": "us-east-2",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "Límite",
                            "value": 70
                        }
                    ]
                },
                "title": "Propiedades eu-west-1"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 8,
            "width": 6,
            "height": 7,
            "properties": {
                "view": "timeSeries",
                "stacked": false,
                "metrics": [
                    [ "AWS/ECS", "CPUUtilization", "ServiceName", "reservas", "ClusterName", "main-cluster", { "region": "eu-west-1" } ],
                    [ ".", "MemoryUtilization", ".", ".", ".", ".", { "region": "eu-west-1" } ]
                ],
                "region": "us-east-2",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "Límite",
                            "value": 70
                        }
                    ]
                },
                "title": "Reservas eu-west-1"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "# Métricas generales"
            }
        }
    ]
}
EOF
}