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

variable "basicauth_enabled" {
  type = string
}

variable "products_import_bucket" {
  type = string
}

variable "rollbar_env" {
  type = string
}

variable "redis_url" {
  type = string
}

variable "security_groups" {
  type = list(string)
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

variable "mail_from" {
  type = string
}

variable "sidekiq_concurrency" {
  type = string
}

variable "sidekiq_concurrency_searchkick" {
  type = string
}

variable "elasticsearch_limit" {
  type = string
}

variable "cnet_ftp_endpoint" {
  type = string
}

variable "cnet_ftp_port" {
  type = string
}

variable "s3_static_bucket_name" {
  type = string
}

variable "new_relic_app_name" {
  type = string
}

variable "new_relic_agent_enabled" {
  type = string
}

variable "rack_timeout_service_timeout" {
  type = string
}

variable "enable_admin_panel_orders" {
  type = string
}

variable "ecs_log_retention_in_days" {
  type = number
}

#########
# Secrets
#########
variable "aws_access_key_id_ssm_arn" {
  type = string
}

variable "aws_secret_access_key_ssm_arn" {
  type = string
}

variable "basicauth_username_ssm_arn" {
  type = string
}

variable "basicauth_password_ssm_arn" {
  type = string
}

variable "cnet_ftp_username_ssm_arn" {
  type = string
}

variable "db_username_ssm_arn" {
  type = string
}

variable "db_password_ssm_arn" {
  type = string
}

variable "logit_hostname_ssm_arn" {
  type = string
}

variable "logit_remote_port_ssm_arn" {
  type = string
}

variable "new_relic_license_key_ssm_arn" {
  type = string
}

variable "rollbar_access_token_ssm_arn" {
  type = string
}

variable "cnet_ftp_password_ssm_arn" {
  type = string
}

variable "sidekiq_username_ssm_arn" {
  type = string
}

variable "sidekiq_password_ssm_arn" {
  type = string
}

variable "secret_key_base_ssm_arn" {
  type = string
}

variable "sendgrid_username_ssm_arn" {
  type = string
}

variable "sendgrid_password_ssm_arn" {
  type = string
}

variable "sendgrid_api_key_ssm_arn" {
  type = string
}

variable "default_country_id" {
  type = string
}

variable "ordnance_survey_api_token_ssm_arn" {
  type = string
}

variable "buyer_organizations_import_bucket" {
  type = string
}

variable "cnet_products_import_bucket" {
  type = string
}

variable "cnet_products_import_updates_dir" {
  type = string
}

variable "sidekiq_concurrency_catalog_reindex" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_feed" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_categories" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_documents" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_images" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_properties" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_xmls" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_missing_properties" {
  type = string
}

variable "sidekiq_concurrency_cnet_import_missing_xmls" {
  type = string
}
