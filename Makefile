# --- VARIABLES ---
REGION ?= us-east-1

# --- COMMANDS ---

build:
	@echo "🏗️ Building Golden Image on AWS (Region: $(REGION))..."
	cd packer && packer init .
	# Building the AMI. Note: storing AMIs on AWS incurs a small cost
	cd packer && packer build -only=amazon-ebs.aws \
		-var "aws_region=$(REGION)" \
		.

deploy:
	@echo "🚀 Provisioning AWS GPU Instance in $(REGION)..."
	cd terraform/aws && terraform init
	# You can change the region or type: make deploy REGION=eu-west-3
	cd terraform/aws && TF_VAR_region=$(REGION) terraform apply -auto-approve

config:
	@echo "🧠 Configuring AI Stack via Ansible..."
	sleep 60
	cd ansible && ansible-playbook -i inventory.ini playbook.yml

destroy:
	@echo "💥 DESTROYING AWS INFRASTRUCTURE..."
	cd terraform/aws && terraform destroy -auto-approve
	rm -f ansible/private_key.pem ansible/inventory.ini

# THE RED BUTTON
run: deploy config
	@echo ""
	@echo "✅ MISSION ACCOMPLISHED (AWS)."
	@echo "---------------------------------------------------"
	@echo "Establish the secure tunnel:"
	@echo "ssh -L 8080:127.0.0.1:8080 -i ansible/private_key.pem ubuntu@$$(cd terraform/aws && terraform output -raw public_ip)"
	@echo "---------------------------------------------------"
	@echo "Access: http://localhost:8080"