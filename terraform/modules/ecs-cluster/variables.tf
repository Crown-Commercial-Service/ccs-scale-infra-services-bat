variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "ec2_instance_type" {
  type = string
}

variable "resource_name_suffix" {
  type = string
}