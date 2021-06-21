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
  ecr_image_id_spree              = "deploy-to-sit-latest"
  ecr_image_id_client             = "deploy-to-sit-latest"
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
  enable_ordering                 = true
  ecr_image_id_s3_virus_scan      = "latest"
  s3_virus_scan_cpu               = 2048
  s3_virus_scan_memory            = 4096
  s3_virus_scan_ec2_instance_type = "t2.large"
  basic_auth_enabled              = false
  new_relic_app_name              = "Bat Spree SiT"
  dev_user_public_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD8Halwg1FWTsqO30Xci6UBLvHNvaKqv2tThr6XH5phO9gDFdmqJ2475Bk4WGBbtE6lWv1967F2GzskLk1AVXzGJNK7rJotLn3UXiMMDHHmRExY2gY/zLwc9Y5RXiZ92BrOgV5K+GYhLkFQgEPKGVxKWzIRbXyo6XZ4hZ7hQjQ8urhMwnWeNaz5wugBuAFqBwCq20bADlT70oi3e/f9EvAyQ8uLFFANLvpBYFiss5Kym0oNPJ+JVnfBjVqrvSCz74f2ryEufFjuGcefaTi2/KVZ/mHhUuvSLqadVyr6zSB9tJv6Lz4A1JAyugnr0KCgriPbY5VVUZKtiFF9Tw5CW+zr"
}
