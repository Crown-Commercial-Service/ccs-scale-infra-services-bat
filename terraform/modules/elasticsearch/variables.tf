variable "vpc_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
