resource "aws_vpc" "us-east-2" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
    region = "us-east-2"

    tags = {
        Name = "main-vpc"
    }
}

resource "aws_vpc" "sa-east-1" {
    cidr_block       = "10.0.0.0/16"
    instance_tenancy = "default"
    region = "sa-east-1"

    tags = {
        Name = "main-vpc"
    }
}