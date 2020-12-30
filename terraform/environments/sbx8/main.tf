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
  source                     = "../../modules/configs/deploy-all"
  aws_account_id             = data.aws_ssm_parameter.aws_account_id.value
  environment                = local.environment
  rollbar_env                = local.environment
  ecr_image_id_spree         = "latest"
  ecr_image_id_client        = "latest"
  client_cpu                 = 4096
  client_memory              = 8192
  client_ec2_instance_type   = "t2.large" #TODO - t2.large is 2/8 - check with Som as doesn't match requirement
  spree_cpu                  = 4096
  spree_memory               = 16384
  spree_ec2_instance_type    = "t2.xlarge"
  sidekiq_cpu                = 4096
  sidekiq_memory             = 16384
  sidekiq_ec2_instance_type_ = "t2.xlarge"
}
