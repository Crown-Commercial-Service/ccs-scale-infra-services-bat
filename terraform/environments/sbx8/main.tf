#########################################################
# Environment: SBX8
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-bat-sbx8"
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
  environment = "SBX8"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source                    = "../../modules/configs/deploy-all"
  aws_account_id            = data.aws_ssm_parameter.aws_account_id.value
  environment               = local.environment
  rollbar_env               = local.environment
  ecr_image_id_spree        = "latest"
  ecr_image_id_client       = "latest"
  client_cpu                = 4096
  client_memory             = 8192        #t2.xlarge - 16GB available
  client_ec2_instance_type  = "t2.xlarge" # NB: Som's initial design was 4/8, Ravi approved use of t2.xlarge as nearest instance size
  spree_cpu                 = 4096
  spree_memory              = 15360 #16GB available - save 1GB for the instance (or increase to t2.xlarge)
  spree_ec2_instance_type   = "t2.xlarge"
  sidekiq_cpu               = 4096
  sidekiq_memory            = 15360 #16GB available - save 1GB for the instance (or increase to t2.xlarge)
  sidekiq_ec2_instance_type = "t2.xlarge"
  memcached_node_type       = "cache.m4.large"
  redis_node_type           = "cache.m4.large"
  az_names                  = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

  # default values for s3-virus-scan-service subject to change based on testing on DEV
  ecr_image_id_s3_virus_scan      = "latest"
  s3_virus_scan_cpu               = 1024
  s3_virus_scan_memory            = 2048
  s3_virus_scan_ec2_instance_type = "t2.medium"
}
