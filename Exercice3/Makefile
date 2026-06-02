.PHONY: deploy fmt validate apply destroy playbook known-hosts display

deploy: fmt validate apply known-hosts playbook display

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
	ansible-playbook -i inventory.yml deploy-haproxy.yml

# This target adds the public DNS names of the created instances to the SSH known_hosts file
known-hosts:
	@sed -i 's/\r$$//' inventory.yml
	@for host in $$(grep ansible_host inventory.yml | awk '{print $$2}'); do \
		echo "Adding $$host to known_hosts..."; \
		ssh-keygen -R $$host >/dev/null 2>&1 || true; \
		until ssh-keyscan -H $$host >> ~/.ssh/known_hosts 2>/dev/null; do \
			echo "SSH not ready yet..."; \
			sleep 2; \
		done \
	done

#	@for host in $$(grep ansible_host inventory.yml | awk '{print $$2}'); do \
#		echo "$$host"; \
# 		ssh-keygen -R $$host >/dev/null 2>&1 || true; \
# 		until ssh-keyscan -H $$host >> ~/.ssh/known_hosts 2>/dev/null; do \
# 			echo "SSH not ready yet..."; \
# 			sleep 2; \
# 		done \
#	done

#	@for host in $$(grep ansible_host inventory.yml | awk '{print $$2}'); do \
#		echo "Adding $$host to known_hosts..."; \
# 		ssh-keygen -R $$host >/dev/null 2>&1 || true; \
# 		until ssh-keyscan -H $$host >> ~/.ssh/known_hosts 2>/dev/null; do \
# 			echo "SSH not ready yet..."; \
# 			sleep 2; \
# 		done \
#	done


# Display outputs
display:
	@echo "SSH Haproxy: $$(terraform output haproxy_ssh)"
	@echo "SSH Webservers: $$(terraform output webserver_ssh)"
	@echo "URL Haproxy: $$(terraform output haproxy_http)"
	@echo "URL Haproxy stats: $$(terraform output haproxy_stats)"
	@echo "URL Webservers: $$(terraform output webserver_http)"