terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 0.14"

  backend "remote" {
    organization = "ACG-terr-lab"

    workspaces {
      name = "demo-github-act"
    }
  }
}


provider "aws" {
  region = "us-west-2"
}



resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami                    = "ami-830c94e3"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "web-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_instance" "web-2" {
  ami                    = "ami-830c94e3"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  tags = {
    Name = "web-2"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!!!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
output "web-address-2" {
  value = "${aws_instance.web-2.public_dns}:8080"
}
