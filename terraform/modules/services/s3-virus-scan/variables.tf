variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "app_port" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "aws_region" {
  type = string
}

variable "ecr_image_id_s3_virus_scan" {
  type = string
}

variable "deployment_maximum_percent" {
  type = number
}

variable "deployment_minimum_healthy_percent" {
  type = number
}

variable "security_groups" {
  type = list(string)
}

