#########################################################
# Environment: DEV
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-bat-dev"
    region         = "eu-west-2"
    dynamodb_table = "scale_terraform_state_lock"
    encrypt        = true
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

locals {
  environment = "DEV"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source                               = "../../modules/configs/deploy-all"
  aws_account_id                       = data.aws_ssm_parameter.aws_account_id.value
  environment                          = local.environment
  rollbar_env                          = local.environment
  ecr_image_id_spree                   = "latest"
  ecr_image_id_client                  = "latest"
  client_cpu                           = 2048
  client_memory                        = 4096 #t2.large - 8GB available
  client_ec2_instance_type             = "t2.large"
  spree_cpu                            = 4096
  spree_memory                         = 8192 #t2.xlarge - 16GB available
  spree_ec2_instance_type              = "t2.xlarge"
  sidekiq_cpu                          = 4096
  sidekiq_memory                       = 8192 #t2.xlarge - 16GB available
  sidekiq_ec2_instance_type            = "t2.xlarge"
  memcached_node_type                  = "cache.t3.medium"
  redis_node_type                      = "cache.t3.medium"
  error_pages_unknonwn_server_endpoint = true
  email_from                           = "bt@sprks.eu"
  enable_ordering                      = true

  # default values for s3-virus-scan-service subject to change based on testing on DEV
  ecr_image_id_s3_virus_scan      = "latest"
  s3_virus_scan_cpu               = 2048
  s3_virus_scan_memory            = 4096
  s3_virus_scan_ec2_instance_type = "t2.large"

  dev_user_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoXva2Ac7GDV/55YViG/2zwxC38/89UZqnuCt+wf1ICxFohdEFi5mMMszlhVgpBk+iA4RFDx3QnRezk5Wf/TmhLw8tv9GUK1s/KyBC7P3JbLtqozNz46A/rj6yudkkCPECsOOVsb3jlRrh15t25eDoQX8Kvw8ML+ShMkjiOvGjdFekue6nHbG0lLrJO3KqgplH0mzttr34tiVVE07dmrFJYpVCedrqeYR8z9qFpN9mtKHRRwHtnzDw3XH7T4MRgWw4PwGuGmmlxk25tlfJnicNGC2hS6e1Ke+Es9uOYTP3MOppcDDgZHXkN/YYVZy5RpjRsgzCAI97osXmQj8yv5on"
}
