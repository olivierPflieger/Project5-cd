output "instance_public_dns" {
  description = "URL pour accéder aux serveurs web"
  value       = "http://${aws_instance.oc_project5.public_dns}"
}

output "webserver_ssh" {
  description = "Commande SSH pour se connecter à l'instance"
  value = "ssh -i ~/.ssh/${aws_key_pair.generated_key.key_name}.pem ubuntu@${aws_instance.oc_project5.public_dns}"
}