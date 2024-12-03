terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_availability_zones" "availability" {}

provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "Main VPC"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = element(data.aws_availability_zones.availability.names,0)
    tags = {
      Name = "Public subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = element(data.aws_availability_zones.availability.names,1)
    tags = {
      Name = "Private subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "Main IGW"
    }
}

resource "aws_route" "public_route" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "Public route table"
    }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "Private route table"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

output "vpc_id" {
    value = aws_vpc.main.id
}