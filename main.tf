provider "aws" {
  region = "us-east-1"

}


terraform {
  backend "s3" {
    bucket = "mytfstatesbucket"
    key    = "TERRAFORM/Terraform-cloud-PR"
    region = "us-east-1"
  }
}




resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "My_test_vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "My_subnet"
  }
}

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My_gw"
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_network_interface" "test" {
  subnet_id       = aws_subnet.my_subnet.id
  security_groups = [aws_security_group.allow_tls.id]

  attachment {
    instance     = aws_instance.my_ubuntu_server.id
    device_index = 1
  }
}




resource "aws_instance" "my_ubuntu_server" {
  ami                    = "ami-00874d747dde814fa"
  instance_type          = "t2.micro"
  user_data              = file("Instal.sh")
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id              = aws_subnet.my_subnet.id

}


resource "aws_route_table" "my_rout" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
}

resource "aws_route_table_association" "rout_ass" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rout.id

}
