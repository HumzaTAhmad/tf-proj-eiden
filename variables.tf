variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = list(any)
}

variable "iam_role_name" {
  description = "The ID of the IAM role"
  type        = string
}

variable "ami_id" {
  description = "The ID of the linux AMI"
  type        = string
}