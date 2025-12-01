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

resource "aws_vpc_endpoint" "sns" {
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${data.aws_region.current.region}.sns"
    vpc_endpoint_type = "Interface"
    subnet_ids        = [ aws_subnet.service-subnets[0].id ]
    security_group_ids = [ aws_security_group.endpoints.id ]
    private_dns_enabled = true
}
resource "aws_vpc_endpoint" "email" {
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${data.aws_region.current.region}.email"
    vpc_endpoint_type = "Interface"
    subnet_ids        = [ aws_subnet.lambda_subnets[0].id ]
    security_group_ids = [ aws_security_group.endpoints.id ]
    private_dns_enabled = true
}

resource "aws_vpc_endpoint" "log" {
    vpc_id            = aws_vpc.this.id
    service_name      = "com.amazonaws.${data.aws_region.current.region}.logs"
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

resource "aws_vpc_endpoint" "dynamodb" {
    vpc_id            = aws_vpc.this.id
    service_name = "com.amazonaws.${data.aws_region.current.region}.dynamodb"
    vpc_endpoint_type = "Gateway"
    route_table_ids   = [ aws_route_table.service.id, aws_route_table.lambda.id ]
}

# ENDPOINTS RULES
resource "aws_vpc_security_group_ingress_rule" "endpoints_a_lambda_enviar_correo" {
    security_group_id = aws_security_group.endpoints.id
    referenced_security_group_id = aws_security_group.enviar_correo.id
    ip_protocol                  = "-1"

    description = "Permitir ingreso del SG de lambda enviar_correo"
}

resource "aws_vpc_security_group_ingress_rule" "endpoints_a_lambda_actualizar_estadistica" {
    security_group_id = aws_security_group.endpoints.id
    referenced_security_group_id = aws_security_group.actualizar_estadisticas.id
    ip_protocol                  = "-1"

    description = "Permitir ingreso del SG de lambda actualizar_estadisticas"
}