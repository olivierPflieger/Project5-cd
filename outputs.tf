output "instance_public_dns" {
  description = "Public DNS de l'instance EC2"
  value       = aws_instance.oc_project5.public_dns
}

output "instance_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.oc_project5.public_ip
}

output "ansible_inventory_path" {
  value = "${path.module}/Ansible/hosts_aws"
}

output "private_key_file_path" {
  value = pathexpand("~/.ssh/${aws_key_pair.generated_key.key_name}.pem")
}

output "ssh_connection_command" {
  description = "Commande SSH pour se connecter à l'instance"

  value = format(
    "ssh -i ~/.ssh/${aws_key_pair.generated_key.key_name}.pem ubuntu@%s",    
     aws_instance.oc_project5.public_dns
  )
}