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

output "alb-subnet" {
    value = aws_subnet.alb-subnet
}

output "app-subnet" {
    value = aws_subnet.app-subnet
}
