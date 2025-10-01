output "vpc-id" {
    value = aws_vpc.this.id
}

output "alb-sg-id" {
    value = aws_security_group.alb-sg.id
}

output "alb-subnet" {
    value = aws_subnet.alb-subnet
}

output "app-subnet" {
    value = aws_subnet.app-subnet
}

output "services-sg-id" {
    value = aws_security_group.services-sg.id
}