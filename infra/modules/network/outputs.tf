output "vpc-id" {
    value = aws_vpc.this.id
}

# SGs

output "alb-sg" {
    value = aws_security_group.alb
}

output "service-sg" {
    value = aws_security_group.service
}

output "vpc-link-sg" {
    value = aws_security_group.vpc-link
}

output "updateStats_sg_id" {
    value = aws_security_group.actualizar_estadisticas.id
}

output "sendEmail_sg_id" {
    value = aws_security_group.enviar_correo.id
}

# Subnets

output "alb-subnets" {
    value = aws_subnet.alb-subnets
}

output "service-subnets" {
    value = aws_subnet.service-subnets
}

output "lambda_subnets" {
    value = aws_subnet.lambda_subnets
}
