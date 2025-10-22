terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.14.1"
    }
  }
}

provider "aws" {
    alias = "ue2"
    region = "us-east-2"
}

provider "aws" {
    alias = "ue1"
    region = "us-east-1"
}

provider "aws" {
    alias = "se1"
    region = "sa-east-1"
}

provider "aws" {
    alias = "ew1"
    region = "eu-west-1"
}
