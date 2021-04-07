#########################################################
# Environment: SBX1
#
# Deploy SCALE resources
#########################################################
terraform {
  backend "s3" {
    bucket         = "scale-terraform-state"
    key            = "ccs-scale-infra-services-bat-sbx1"
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
  environment = "SBX1"
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
  client_memory             = 7168 #8192
  client_ec2_instance_type  = "t2.large"
  spree_cpu                 = 2048
  spree_memory              = 7168 #8192
  spree_ec2_instance_type   = "t2.large"
  sidekiq_cpu               = 2048
  sidekiq_memory            = 7168 #8192
  sidekiq_ec2_instance_type = "t2.large"
  dev_user_public_key       = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCaHta2G06kHC/9d0g2mE+y5K9LTb/FAwqeu/LqRk5E4Ebd6dzEpo0+arONcu/kFbfSRxTUQZ+h4HcbsfLz50r5R1LN6fnjXh74gluElUdc8Fye7Y8DvYnru0Clk9WA1w2CI9ARbsH15pymV9HeY7D/I/1AXc5P8ESFyMTbxgxnoAZ/FGDGIr9P0ahGMb/qpCyxCoTv6TliQ2dCrhEjwKLPaf5C73ptyZJrh9HXpB6utnu/fa0T/QFfN6dvhjuLdgj701epWBfMRChXgZeuWRDGyxIj6YTBw8PlRiPuHuP1xU4pJLYjcvSBY4ol3ySMuHqpVK/3F/BZ0Y6rhhnEy42Z"
}
