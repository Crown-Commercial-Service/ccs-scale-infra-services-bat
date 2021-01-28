
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

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "aws_region" {
  type = string
}

variable "client_app_host" {
  type = string
}

variable "spree_api_host" {
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

variable "logit_hostname" {
  type = string
}

variable "logit_remote_port" {
  type = string
}

variable "hosted_zone_name" {
  type = string
}

variable "documents_terms_and_conditions_url" {
  type = string
}

variable "deployment_maximum_percent" {
  type = number
}

variable "deployment_minimum_healthy_percent" {
  type = number
}

variable "logit_node" {
  type = string
}
