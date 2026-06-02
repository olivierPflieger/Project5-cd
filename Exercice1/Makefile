.PHONY: deploy fmt validate apply destroy playbook ping known-hosts display

deploy: fmt validate apply known-hosts ping playbook display

# Terraform
fmt:
	terraform fmt

validate:
	terraform validate

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

# Ansible
playbook:
	ansible-playbook -i inventory.yml playbook.yml

ping:
	ansible all -i inventory.yml -m ping

# This target adds the public DNS names of the created instances to the SSH known_hosts file
known-hosts:
	@host=$$(grep ansible_host inventory.yml | awk '{print $$2}'); \
	echo "Adding $$host to known_hosts..."; \
	ssh-keygen -R $$host >/dev/null 2>&1 || true; \
	until ssh-keyscan -H $$host >> ~/.ssh/known_hosts 2>/dev/null; do \
		echo "SSH not ready yet..."; \
		sleep 5; \
	done

# Display outputs
display:
	@echo "SSH Webserver: $$(terraform output webserver_ssh)"
	@echo "URL WebServer: $$(terraform output instance_public_dns)"
