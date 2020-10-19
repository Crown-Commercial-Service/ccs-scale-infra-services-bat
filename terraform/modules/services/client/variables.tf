
variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

#variable "lb_public_arn" {
#  type = string
#}

variable "lb_public_alb_arn" {
  type = string
}

variable "public_web_subnet_ids" {
  type = list(string)
}

variable "client_app_port" {
  type = string
}

variable "client_cpu" {
  type = number
}

variable "client_memory" {
  type = number
}

variable "aws_region" {
  type = string
}

variable "papertrail_hostname" {
  type = string
}

variable "papertrail_remote_port" {
  type = string
}

variable "rollbar_access_token" {
  type = string
}

variable "basicauth_username" {
  type = string
}

variable "basicauth_password" {
  type = string
}

variable "basicauth_enabled" {
  type = string
}

variable "client_session_secret" {
  type = string
}

variable "rollbar_env" {
  type = string
}

variable "spree_image_host" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "env_file" {
  type = string
}

variable "cloudfront_id" {
  type = string
}

variable "ecr_image_id_client" {
  type = string
}
