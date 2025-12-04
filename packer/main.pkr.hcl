packer {
  required_plugins {
    amazon    = { version = ">= 1.0.0", source = "github.com/hashicorp/amazon" }
  }
}

# --- DYNAMIC VARIABLES ---

variable "image_name" { default = "blackops-llm-v1" }

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# --- AWS SOURCE ---
source "amazon-ebs" "aws" {
  region          = var.aws_region
  instance_type   = "g4dn.xlarge"
  ssh_username    = "ubuntu"
  ami_name        = "${var.image_name}-{{timestamp}}"
  
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
}

build {
  sources = [
    "source.amazon-ebs.aws"
  ]

  provisioner "shell" {
    script          = "./scripts/install_gpu.sh"
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E -S sh '{{ .Path }}'"
    timeout         = "30m"
  }
}