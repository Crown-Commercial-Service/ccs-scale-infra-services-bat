
variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

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

variable "basicauth_enabled" {
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

variable "cloudfront_id" {
  type = string
}

variable "ecr_image_id_client" {
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

variable "enable_basket" {
  type = string
}

variable "enable_quotes" {
  type = string
}

variable "logit_application" {
  type = string
}

variable "error_pages_unknonwn_server_endpoint" {
  type = string
}

#########
# Secrets
#########
variable "rollbar_access_token_ssm_arn" {
  type = string
}

variable "basicauth_username_ssm_arn" {
  type = string
}

variable "basicauth_password_ssm_arn" {
  type = string
}

variable "client_session_secret_ssm_arn" {
  type = string
}

variable "browser_rollbar_access_token_ssm_arn" {
  type = string
}

variable "logit_hostname_ssm_arn" {
  type = string
}

variable "logit_remote_port_ssm_arn" {
  type = string
}

variable "logit_node_ssm_arn" {
  type = string
}
