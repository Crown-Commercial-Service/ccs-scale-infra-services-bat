variable "aws_account_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "az_names" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

#######################
# SPREE SHARED
#######################
# (used to be param: //bar/{env}-basic-auth-enabled)
variable "basic_auth_enabled" {
  type    = bool
  default = true
}

#######################
# SPREE CLIENT
#######################
variable "ecr_image_id_client" {
  type    = string
  default = "latest"
}

variable "client_ec2_instance_type" {
  type    = string
  default = "t2.medium"
}

variable "default_country_id" {
  type    = string
  default = 77
}

variable "client_cpu" {
  type    = number
  default = 2048
}

variable "client_memory" {
  type    = number
  default = 4096
}

# (used to be param: /bat/{env}-documents-terms-and-conditions-url)
variable "documents_terms_and_conditions_url" {
  type    = string
  default = "https://www.crowncommercial.gov.uk/agreements/RM6147"
}

# (used to be param: /bat/{env}-enable-quotes)
variable "enable_quotes" {
  type    = bool
  default = true
}

# (used to be param: /bat/{env}-enable-basket)
variable "enable_basket" {
  type    = bool
  default = true
}

# (used to be param: /bat/{env}-sidekiq-concurrency)
variable "sidekiq_concurrency" {
  type    = number
  default = 100
}

# (used to be param: /bat/{env}-sidekiq-concurrency-searchkick)
variable "sidekiq_concurrency_searchkick" {
  type    = number
  default = 40
}

# (used to be param: /bat/{env}-logit-application)
variable "logit_application" {
  type    = string
  default = null # this is purposfully null as we do a null check in the main.tf
}

# (used to be env var: ERROR_PAGES_EXPOSE_UNKNOWN_SERVER_ERROR_ENDPOINT)
variable "error_pages_unknonwn_server_endpoint" {
  type    = bool
  default = false
}

#######################
# SPREE BACKEND
#######################
variable "ecr_image_id_spree" {
  type    = string
  default = "latest"
}

variable "spree_ec2_instance_type" {
  type    = string
  default = "t2.xlarge"
}

variable "spree_cpu" {
  type    = number
  default = 4096
}

variable "spree_memory" {
  type    = number
  default = 8192
}

# (used to be param: /bat/{env}-elasticsearch-limit)
variable "elasticsearch_limit" {
  type    = number
  default = 12
}

# (used to be param: /bat/{env}-mail-from)
variable "email_from" {
  type    = string
  default = "SupplierRef@findandbuyproducts.crowncommercial.gov.uk"
}

# (used to be param: /bat/{env}-cnet-ftp-endpoint)
variable "cnet_ftp_endpoint" {
  type    = string
  default = "ftp.cnetcontentsolutions.com"
}

# (used to be param: /bat/{env}-cnet-ftp-port)
variable "cnet_ftp_port" {
  type    = number
  default = 21
}

# (used to be param: /bat/{env}-lograge-enabled)
variable "lograge_enabled" {
  type    = bool
  default = true
}

# (used to be env var: NEW_RELIC_APP_NAME from spree.env)
variable "new_relic_app_name" {
  type    = string
  default = null # this is purposfully null as we do a null check in the main.tf
}

# (used to be env var: NEW_RELIC_AGENT_ENABLED from spree.env)
variable "new_relic_agent_enabled" {
  type    = bool
  default = true
}

variable "cnet_products_import_updates_dir" {
  type    = string
  default = "initial_import"
}

#######################
# SPREE SIDEKIQ
#######################
variable "sidekiq_ec2_instance_type" {
  type    = string
  default = "t2.xlarge"
}

variable "sidekiq_cpu" {
  type    = number
  default = 4096
}

variable "sidekiq_memory" {
  type    = number
  default = 8192
}

variable "sidekiq_concurrency_catalog_reindex" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_feed" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_categories" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_documents" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_images" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_properties" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_xmls" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_missing_properties" {
  type    = number
  default = 1
}

variable "sidekiq_concurrency_cnet_import_missing_xmls" {
  type    = number
  default = 1
}

#######################
# ROLLBAR
#######################
variable "rollbar_env" {
  type = string
}

#######################
# MEMCACHED
#######################
variable "memcached_node_type" {
  type    = string
  default = "cache.t3.medium"
}

#######################
# REDIS
#######################
variable "redis_node_type" {
  type    = string
  default = "cache.t3.medium"
}

#######################
# AUTH SERVICE
#######################
variable "ecr_image_id_auth" {
  type    = string
  default = "d1d128d-candidate"
}

variable "auth_cpu" {
  type    = number
  default = 512
}

variable "auth_memory" {
  type    = number
  default = 1024
}

#######################
# CATALOGUE SERVICE
#######################
variable "ecr_image_id_catalogue" {
  type    = string
  default = "616acaf-candidate"
}

variable "catalogue_cpu" {
  type    = number
  default = 512
}

variable "catalogue_memory" {
  type    = number
  default = 1024
}

#######################
# S3 VIRUS SCAN SERVICE
#######################
variable "ecr_image_id_s3_virus_scan" {
  type    = string
  default = "latest"
}

# TODO: Has this been specified?
variable "s3_virus_scan_ec2_instance_type" {
  type    = string
  default = "t2.xlarge"
}

# TODO: Has this been specified?
variable "s3_virus_scan_cpu" {
  type    = number
  default = 4096
}

# TODO: Has this been specified?
variable "s3_virus_scan_memory" {
  type    = number
  default = 8192
}

#######################
# BAT API GATEWAY
#######################
variable "stage" {
  type    = string
  default = "staging"
}

variable "api_rate_limit" {
  type    = number
  default = 10000
}

variable "api_burst_limit" {
  type    = number
  default = 5000
}

variable "api_gw_log_retention_in_days" {
  type    = number
  default = 7
}

#######################
# ECS
#######################
variable "deployment_maximum_percent" {
  type    = number
  default = 100
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 50
}

variable "ecs_log_retention_in_days" {
  type    = number
  default = 7
}
