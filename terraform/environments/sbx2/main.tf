#########################################################
# Environment: SBX2
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-bat-sbx2"
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
  environment = "SBX2"
}

data "aws_ssm_parameter" "aws_account_id" {
  name = "account-id-${lower(local.environment)}"
}

module "deploy" {
  source                    = "../../modules/configs/deploy-all"
  aws_account_id            = data.aws_ssm_parameter.aws_account_id.value
  environment               = local.environment
  rollbar_env               = local.environment
  client_cpu                = 2048
  client_memory             = 3548 #4096
  client_ec2_instance_type  = "t2.medium"
  spree_cpu                 = 2048
  spree_memory              = 7168 #8192
  spree_ec2_instance_type   = "t2.large"
  sidekiq_cpu               = 2048
  sidekiq_memory            = 7168 #8192
  sidekiq_ec2_instance_type = "t2.large"

  # Made these small for SBX environments (what should default be?)
  s3_virus_scan_cpu               = 1024
  s3_virus_scan_memory            = 1536
  s3_virus_scan_ec2_instance_type = "t2.small"
}
