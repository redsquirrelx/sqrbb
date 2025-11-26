data "aws_availability_zones" "available" {
    state = "available"
}

## ALB_SUBNET

resource "aws_subnet" "alb-subnets" {
    count = length(data.aws_availability_zones.available.names)
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet("10.0.0.0/16", 8, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "alb-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
}

resource "aws_route_table" "alb" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }

    tags = {
      Name = "alb-subnet-rt"
    }
}

resource "aws_route_table_association" "alb" {
    count = length(aws_subnet.alb-subnets)
    subnet_id      = aws_subnet.alb-subnets[count.index].id
    route_table_id = aws_route_table.alb.id
}

## APP_SUBNET
resource "aws_subnet" "service-subnets" {
   count = length(data.aws_availability_zones.available.names)
   vpc_id = aws_vpc.this.id
   cidr_block = cidrsubnet("10.0.128.0/17", 3, count.index)
   availability_zone = data.aws_availability_zones.available.names[count.index]
   tags = {
       Name = "service-subnet-${data.aws_availability_zones.available.names[count.index]}"
   }
}

resource "aws_route_table" "service" {
   vpc_id = aws_vpc.this.id

   route {
       cidr_block = "10.0.0.0/16"
       gateway_id = "local"
   }

   tags = {
     Name = "service-subnet-rt"
   }
}

resource "aws_route_table_association" "service" {
    count           = length(aws_subnet.service-subnets)
    subnet_id       = aws_subnet.service-subnets[count.index].id
    route_table_id  = aws_route_table.service.id
}

# LAMBDA SUBNETS
resource "aws_subnet" "lambda_subnets" {
    count = length(data.aws_availability_zones.available.names)
    vpc_id = aws_vpc.this.id
    cidr_block = cidrsubnet("10.0.224.0/24", 2, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = {
        Name = "lambda-subnet-${data.aws_availability_zones.available.names[count.index]}"
    }
}

resource "aws_route_table" "lambda" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "10.0.0.0/16"
        gateway_id = "local"
    }
}

resource "aws_route_table_association" "lambda" {
    count = length(aws_subnet.lambda_subnets)
    subnet_id      = aws_subnet.lambda_subnets[count.index].id
    route_table_id = aws_route_table.lambda.id
}