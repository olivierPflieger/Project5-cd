all:
  children:
    webservers:
      hosts:
%{ for name, server in webservers ~}
        ${name}:
          ansible_host: ${server.public_dns}
          private_ip: ${server.private_ip}
%{ endfor ~}

  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/${key_name}.pem