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

variable "env_file" {
  type = string
}

variable "redis_url" {
  type = string
}

variable "elasticsearch_url" {
  type = string
}

variable "memcached_endpoint" {
  type = string
}

variable "app_domain" {
  type = string
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_access_key" {
  type = string
}

variable "s3_region" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "security_groups" {
  type = list(string)
}
