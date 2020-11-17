variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "lb_suffix" {
  type = string
}

variable "public_web_subnet_ids" {
  type = list(string)
}

variable "hosted_zone_name" {
  type = string
}
