resource "aws_vpc" "us-east-2" {
    provider = aws.us-east-2

    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "main-vpc"
    }
}

resource "aws_vpc" "sa-east-1" {
    provider = aws.sa-east-1
    
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"

    tags = {
        Name = "main-vpc"
    }
}