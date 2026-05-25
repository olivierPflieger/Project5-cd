provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "oc_project5" {

  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t3.micro"

  tags = {
    Name = "OpenClassrooms-EDO-P5"
  }

  vpc_security_group_ids = ["${aws_security_group.oc_project5_sg.id}"]
  key_name               = "oc-project5-key-us-east-1"
}

resource "aws_security_group" "oc_project5_sg" {
  name = "allow-ssh"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}