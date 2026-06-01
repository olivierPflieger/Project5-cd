output "webserver_ssh" {
  description = "Commande SSH pour se connecter aux serveurs web"
  value = { for i in aws_instance.webserver : i.tags.Name => "ssh -i ~/.ssh/aws_${aws_key_pair.generated_key.key_name}.pem -o IdentitiesOnly=yes ubuntu@${i.public_dns}"
  }
}

output "webserver_http" {
  description = "URL pour accéder aux serveurs web"
  value = { for i in aws_instance.webserver : i.tags.Name => "http://${i.public_dns}"
  }
}

output "haproxy_ssh" {
  description = "Commande SSH pour se connecter au serveur HAProxy"
  value = "ssh -i ~/.ssh/aws_${aws_key_pair.generated_key.key_name}.pem -o IdentitiesOnly=yes ubuntu@${aws_instance.haproxy.public_dns}"  
}

output "haproxy_http" {
  description = "URL pour accéder au load balancer HAProxy"
  value = "http://${aws_instance.haproxy.public_dns}"
}

output "haproxy_stats" {
  description = "URL pour accéder aux statistiques HAProxy"
  value = "http://${aws_instance.haproxy.public_dns}:8404/stats"
}
