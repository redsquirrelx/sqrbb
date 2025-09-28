terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "6.14.1"
    }
  }
}

provider "aws" {
    region = "us-east-2"
}

provider "aws" {
    alias = "us-east-2"
    region = "us-east-2"
}

provider "aws" {
    alias = "sa-east-1"
    region = "sa-east-1"
}