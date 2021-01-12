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

variable "lb_public_alb_arn" {
  type = string
}

variable "lb_public_alb_dns" {
  type = string
}

variable "lb_private_nlb_arn" {
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

variable "db_name" {
  type = string
}

variable "db_host" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "secret_key_base" {
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

variable "products_import_bucket" {
  type = string
}

variable "rollbar_env" {
  type = string
}

variable "env_file" {
  type = string
}

variable "redis_url" {
  type = string
}

variable "memcached_endpoint" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "cloudfront_id" {
  type = string
}

variable "elasticsearch_url" {
  type = string
}

variable "buyer_ui_url" {
  type = string
}

variable "ecr_image_id_spree" {
  type = string
}

variable "app_domain" {
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

variable "suppliers_sftp_bucket" {
  type = string
}

variable "deployment_maximum_percent" {
  type = number
}

variable "deployment_minimum_healthy_percent" {
  type = number
}

variable "lograge_enabled" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "mail_from" {
  type = string
}
