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
  key_name               = aws_key_pair.generated_key.key_name
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

// Création paire de clés SSH
resource "tls_private_key" "my_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.my_ssh_key.public_key_openssh
}

// On stocke notre clé SSH privée localement dans le répertoire ~/.ssh
resource "local_sensitive_file" "pem_file" {
  filename             = pathexpand("~/.ssh/${aws_key_pair.generated_key.key_name}.pem")
  file_permission      = "600"
  directory_permission = "700"

  content = tls_private_key.my_ssh_key.private_key_pem
}

# Generate a YAML inventory for Ansible
resource "local_file" "ansible_inventory_yaml" {
  content = templatefile("${path.module}/inventory.yml.tpl", {
    public_dns = aws_instance.oc_project5.public_dns
    private_ip = aws_instance.oc_project5.private_ip
    key_name   = aws_key_pair.generated_key.key_name
  })

  filename = "${path.module}/inventory.yml"
}
