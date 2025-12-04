variable "region" {
  description = "AWS Region"
  # Essaie l'Oregon (souvent plus cool sur les GPU) ou Paris
  default     = "us-east-1" 
}

variable "instance_type" {
  description = "Instance type"
  default     = "g4dn.xlarge" # Nvidia T4 (16GB VRAM) - Le standard pas cher
}