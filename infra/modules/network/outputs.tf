output "vpc-id" {
    value = aws_vpc.this.id
}

output "alb-sg-id" {
    value = aws_security_group.alb-sg.id
}

output "alb-subnet" {
    value = aws_subnet.alb-subnet
}