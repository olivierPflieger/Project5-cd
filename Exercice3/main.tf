terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "webserver" {
  count         = 2
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t3.micro"
  tags = {
    Name = "OpenClassrooms-P5-Webserver-${count.index}"
  }
  vpc_security_group_ids = ["${aws_security_group.my_security_group.id}"]
  key_name               = aws_key_pair.generated_key.key_name
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.my_ssh_key.private_key_pem
    host        = self.public_ip
  }
  provisioner "local-exec" {
    command = "sed -i 's/\r$//' install-webserver.sh"
  }
  provisioner "remote-exec" {
    script = "./install-webserver.sh"
  }
}

resource "aws_instance" "haproxy" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t3.micro"
  tags = {
    Name = "OpenClassrooms-P5-HAProxy"
  }
  vpc_security_group_ids = ["${aws_security_group.haproxy_security_group.id}"]
  key_name               = aws_key_pair.generated_key.key_name
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.my_ssh_key.private_key_pem
    host        = self.public_ip
  }
  provisioner "file" {
    content = templatefile("${path.module}/haproxy.cfg.tpl", {
      ipserver0 = aws_instance.webserver[0].private_ip
      ipserver1 = aws_instance.webserver[1].private_ip
    })

    destination = "/tmp/haproxy.cfg"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y haproxy",
      "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo sed -i 's/\r$//' /etc/haproxy/haproxy.cfg",
      "sudo haproxy -c -f /etc/haproxy/haproxy.cfg",
      "sudo systemctl restart haproxy"
    ]
  }
}

resource "aws_security_group" "my_security_group" {
  name = "OpenClassrooms-P5-EDO"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "haproxy_security_group" {
  name = "OpenClassrooms-P5-HAProxy"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8404
    to_port     = 8404
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.my_ssh_key.public_key_openssh
}

resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("~/.ssh/aws_${aws_key_pair.generated_key.key_name}.pem")
  file_permission      = "600"
  directory_permission = "700"
  content              = tls_private_key.my_ssh_key.private_key_pem
}

# for i in aws_instance.webserver : i.tags.Name => "http://${i.public_dns}"

# Generate a YAML inventory for Ansible
resource "local_file" "ansible_inventory_yaml" {
  content = templatefile("${path.module}/inventory.yml.tpl", {
    webservers = {
      for i, instance in aws_instance.webserver :
      "web${i}" => {
        public_dns = instance.public_dns
        private_ip  = instance.private_ip
      }
    }

    key_name = "aws_${aws_key_pair.generated_key.key_name}.pem"
  })

  filename = "${path.module}/inventory.yml"
}
