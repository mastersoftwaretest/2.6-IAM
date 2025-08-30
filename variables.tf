variable "name" {
  type        = string
  description = "Prefix name for resources"
  default     = "jiaqing"  # optional default
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
  default     = "ami-0de716d6197524dd9"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair Name"
  default     = "jq-key-pair"  # optional, or you can provide in terraform.tfvars
}