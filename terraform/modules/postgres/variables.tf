variable "vpc_id" {
  type = string
}

variable "stage" {
  type = string
}

variable "db_password" {
  type = string
}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
