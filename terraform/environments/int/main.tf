#########################################################
# Environment: INT
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-bat-int"
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
  environment = "INT"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source                          = "../../modules/configs/deploy-all"
  aws_account_id                  = data.aws_ssm_parameter.aws_account_id.value
  environment                     = local.environment
  rollbar_env                     = local.environment
  client_cpu                      = 2048
  client_memory                   = 4096 #t2.large - 8GB available
  client_ec2_instance_type        = "t2.large"
  spree_cpu                       = 4096
  spree_memory                    = 8192 #t2.xlarge - 16GB available
  spree_ec2_instance_type         = "t2.xlarge"
  sidekiq_cpu                     = 4096
  sidekiq_memory                  = 8192 #t2.xlarge - 16GB available
  sidekiq_ec2_instance_type       = "t2.xlarge"
  memcached_node_type             = "cache.t3.medium"
  redis_node_type                 = "cache.t3.medium"
  ecr_image_id_s3_virus_scan      = "latest"
  s3_virus_scan_cpu               = 2048
  s3_virus_scan_memory            = 4096
  s3_virus_scan_ec2_instance_type = "t2.large"
}
