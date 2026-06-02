all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: ${public_dns}
          private_ip: ${private_ip}

  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/${key_name}.pem
