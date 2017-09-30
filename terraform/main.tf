provider "aws" {
    region     = "us-west-2"
}

## VPC ##

resource "aws_vpc" "vpc" {
    cidr_block = "10.0.0.0/24"
    enable_dns_hostnames = true
    tags {
        Name = "${var.name}_vpc"
    }
}

## Internet Gateway ##

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.vpc.id}"
}

## Route Table ##

resource "aws_route_table" "public_route_table" {
    vpc_id = "${aws_vpc.vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }
    tags {
        Name = "Public Subnet Route Table"
    }
}

## Public Route ##

resource "aws_route" "public_route_internet" {
    route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

## Publc Subnet ##

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.0.0/28"
  map_public_ip_on_launch = true
  tags {
        Name = "${var.name}_public_subnet"
  }
}

## Route Table Association ##

resource "aws_route_table_association" "rtra1" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

## Elastic IP ##

resource "aws_eip" "eip" {
    vpc = true
}

## NAT Gateway ##

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = "${aws_eip.eip.id}"
    subnet_id = "${aws_subnet.public_subnet.id}"
}

## Security Group ##

resource "aws_security_group" "security_group" {
  name        = "${var.name}_security_group"
  description = "security group for access control management of instances"
  vpc_id      = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.name}_security_group"
  }

}

## Inbound SSH ##

resource "aws_security_group_rule" "ssh_access" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_group_id = "${aws_security_group.security_group.id}"
    cidr_blocks = ["0.0.0.0/0"]
}

## EC2 Instance ##

resource "aws_instance" "instance" {
  instance_type = "${var.instance_type}"
  ami = "${var.ami}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.security_group.id}"]
  subnet_id = "${aws_subnet.public_subnet.id}"
  tags {
    Name = "${var.name}"
  }
}
