## ALB_SUBNET
resource "aws_subnet" "alb-subnet" {
    vpc_id = aws_vpc.this.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "alb-subnet"
    }
}

resource "aws_route_table" "alb-subnet-rt" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
      Name = "alb-subnet-rt"
    }
}

resource "aws_route_table_association" "alb-subnet-rta" {
  subnet_id      = aws_subnet.alb-subnet.id
  route_table_id = aws_route_table.alb-subnet-rt.id
}

## APP_SUBNET
resource "aws_subnet" "app-subnet" {
    vpc_id = aws_vpc.this.id
    cidr_block = "10.0.192.0/20"
    tags = {
        Name = "app-subnet"
    }
}