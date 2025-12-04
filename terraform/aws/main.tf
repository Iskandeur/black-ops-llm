terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    local = { source = "hashicorp/local" }
    tls = { source = "hashicorp/tls" }
  }
}

provider "aws" {
  region = var.region
}

# 1. Find the image created by Packer
data "aws_ami" "llm_image" {
  most_recent = true
  owners      = ["self"] # Search in YOUR private images
  filter {
    name   = "name"
    values = ["blackops-llm-*"] # The pattern defined in Packer
  }
}

# 2. Create an SSH key on the fly
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "blackops-aws-key"
  public_key = tls_private_key.pk.public_key_openssh
}

# 3. Security (Firewall)
resource "aws_security_group" "allow_ssh" {
  name        = "blackops-allow-ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can restrict to your IP if you want
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. GPU Instance
resource "aws_instance" "gpu_node" {
  ami           = data.aws_ami.llm_image.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

    # --- BLACK OPS ADDITION: SPOT INSTANCE ---
  # Request a "Spot" instance (cheaper).
  # Sometimes Spot quotas are more flexible for new accounts.
  #instance_market_options {
  #  market_type = "spot"
  #  spot_options {
  #    max_price = "0.25" # Set a reasonable max price (on-demand price is ~0.50)
  #    spot_instance_type = "one-time"
  #  }
  #}
  # ---------------------------------------
  
  # Storage: Ensure enough space for models (100GB)
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  tags = {
    Name = "BlackOps-LLM-Node"
  }
}

# 5. Save private key for Ansible
resource "local_file" "private_key" {
  content         = tls_private_key.pk.private_key_pem
  filename        = "${path.module}/../../ansible/private_key.pem"
  file_permission = "0600"
}

# 6. Generate Ansible inventory
resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    ip = aws_instance.gpu_node.public_ip
  })
  filename = "${path.module}/../../ansible/inventory.ini"
}

output "public_ip" {
  value = aws_instance.gpu_node.public_ip
}