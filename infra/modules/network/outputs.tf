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
