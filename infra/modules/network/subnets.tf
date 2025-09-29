## ALB_SUBNET
data "aws_availability_zones" "available" {
    state = "available"
}

resource "aws_subnet" "alb-subnet" {
    count = length(data.aws_availability_zones.available.names)
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "alb-subnet-${data.aws_availability_zones.available.names[count.index]}"
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
    count = length(aws_subnet.alb-subnet)
    subnet_id      = aws_subnet.alb-subnet[count.index].id
    route_table_id = aws_route_table.alb-subnet-rt.id
}

## APP_SUBNET
resource "aws_subnet" "app-subnet" {
   count = length(data.aws_availability_zones.available.names)
   vpc_id = aws_vpc.this.id
   cidr_block = cidrsubnet("10.0.128.0/17", 3, count.index)
   availability_zone = data.aws_availability_zones.available.names[count.index]
   tags = {
       Name = "app-subnet-${data.aws_availability_zones.available.names[count.index]}"
   }
}

resource "aws_route_table" "app-subnet-rt" {
   vpc_id = aws_vpc.this.id

   route {
       cidr_block = "10.0.0.0/16"
       gateway_id = "local"
   }

   tags = {
     Name = "app-subnet-rt"
   }
}

resource "aws_route_table_association" "app-subnet-rta" {
    count           = length(aws_subnet.alb-subnet)
    subnet_id       = aws_subnet.app-subnet[count.index].id
    route_table_id  = aws_route_table.app-subnet-rt.id
}