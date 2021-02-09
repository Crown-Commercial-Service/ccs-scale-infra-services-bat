#########################################################
# Config: deploy-all
#
# This configuration will deploy all components.
#########################################################
provider "aws" {
  profile = "default"
  region  = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/CCS_SCALE_Build"
  }
}

locals {
  aws_region    = "eu-west-2"
  spree_db_name = "spree"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "${lower(var.environment)}-vpc-id"
}

data "aws_ssm_parameter" "public_web_subnet_ids" {
  name = "${lower(var.environment)}-public-web-subnet-ids"
}

data "aws_ssm_parameter" "private_app_subnet_ids" {
  name = "${lower(var.environment)}-private-app-subnet-ids"
}

data "aws_ssm_parameter" "private_db_subnet_ids" {
  name = "${lower(var.environment)}-private-db-subnet-ids"
}

data "aws_ssm_parameter" "vpc_link_id" {
  name = "${lower(var.environment)}-vpc-link-id"
}

data "aws_ssm_parameter" "lb_private_arn" {
  name = "${lower(var.environment)}-lb-private-arn"
}

data "aws_ssm_parameter" "lb_private_dns" {
  name = "${lower(var.environment)}-lb-private-dns"
}

data "aws_ssm_parameter" "bat_client_cloudfront_id" {
  name = "${lower(var.environment)}-bat-client-cloudfront-id"
}

data "aws_ssm_parameter" "bat_backend_cloudfront_id" {
  name = "${lower(var.environment)}-bat-backend-cloudfront-id"
}

data "aws_ssm_parameter" "spree_db_endpoint" {
  name = "/bat/${lower(var.environment)}-spree-db-endpoint"
}

#######################################################
# Following need to be added manually as SSM Parameters
#######################################################
data "aws_ssm_parameter" "rollbar_access_token" {
  name = "/bat/${lower(var.environment)}-rollbar-access-token"
}

data "aws_ssm_parameter" "secret_key_base" {
  name = "/bat/${lower(var.environment)}-secret-key-base"
}

data "aws_ssm_parameter" "basic_auth_username" {
  name = "/bat/${lower(var.environment)}-basic-auth-username"
}

data "aws_ssm_parameter" "basic_auth_password" {
  name = "/bat/${lower(var.environment)}-basic-auth-password"
}

data "aws_ssm_parameter" "basic_auth_enabled" {
  name = "/bat/${lower(var.environment)}-basic-auth-enabled"
}

data "aws_ssm_parameter" "client_session_secret" {
  name = "/bat/${lower(var.environment)}-session-cookie-secret"
}

data "aws_ssm_parameter" "products_import_bucket" {
  name = "/bat/${lower(var.environment)}-products-import-bucket"
}

data "aws_ssm_parameter" "spree_db_username" {
  name            = "/bat/${lower(var.environment)}-spree-db-app-username"
  with_decryption = true
}

data "aws_ssm_parameter" "spree_db_password" {
  name            = "/bat/${lower(var.environment)}-spree-db-app-password"
  with_decryption = true
}

data "aws_ssm_parameter" "elasticsearch_url" {
  name = "/bat/${lower(var.environment)}-elasticsearch-url"
}

data "aws_ssm_parameter" "logit_hostname" {
  name = "/bat/${lower(var.environment)}-logit-hostname"
}

data "aws_ssm_parameter" "logit_remote_port" {
  name = "/bat/${lower(var.environment)}-logit-remote-port"
}

data "aws_ssm_parameter" "hosted_zone_name_alb_bat_client" {
  name = "/bat/${lower(var.environment)}-hosted-zone-name-alb-bat-client"
}

data "aws_ssm_parameter" "hosted_zone_name_cdn_bat_client" {
  name = "/bat/${lower(var.environment)}-hosted-zone-name-cdn-bat-client"
}

data "aws_ssm_parameter" "hosted_zone_name_alb_bat_backend" {
  name = "/bat/${lower(var.environment)}-hosted-zone-name-alb-bat-backend"
}

data "aws_ssm_parameter" "hosted_zone_name_cdn_bat_backend" {
  name = "/bat/${lower(var.environment)}-hosted-zone-name-cdn-bat-backend"
}

data "aws_ssm_parameter" "suppliers_sftp_bucket" {
  name = "/bat/${lower(var.environment)}-suppliers-sftp-bucket"
}

data "aws_ssm_parameter" "documents_terms_and_conditions_url" {
  name = "/bat/${lower(var.environment)}-documents-terms-and-conditions-url"
}

data "aws_ssm_parameter" "lograge_enabled" {
  name = "/bat/${lower(var.environment)}-lograge-enabled"
}

data "aws_ssm_parameter" "sendgrid_api_key" {
  name = "/bat/${lower(var.environment)}-sendgrid-api-key"
}

data "aws_ssm_parameter" "mail_from" {
  name = "/bat/${lower(var.environment)}-mail-from"
}

data "aws_ssm_parameter" "aws_access_key_id" {
  name = "/bat/${lower(var.environment)}-aws-access-key-id"
}
data "aws_ssm_parameter" "aws_secret_access_key" {
  name = "/bat/${lower(var.environment)}-aws-secret-access-key"
}

data "aws_ssm_parameter" "sidekiq_concurrency" {
  name = "/bat/${lower(var.environment)}-sidekiq-concurrency"
}

data "aws_ssm_parameter" "sidekiq_concurrency_searchkick" {
  name = "/bat/${lower(var.environment)}-sidekiq-concurrency-searchkick"
}

data "aws_ssm_parameter" "logit_node" {
  name = "/bat/${lower(var.environment)}-logit-node"
}

data "aws_ssm_parameter" "browser_rollbar_access_token" {
  name = "/bat/${lower(var.environment)}-browser-rollbar-access-token"
}

data "aws_ssm_parameter" "lb_public_alb_arn" {
  name = "${lower(var.environment)}-lb-public-alb-arn"
}

data "aws_ssm_parameter" "enable_basket" {
  name = "/bat/${lower(var.environment)}-enable-basket"
}

data "aws_ssm_parameter" "enable_quotes" {
  name = "/bat/${lower(var.environment)}-enable-quotes"
}

data "aws_ssm_parameter" "elasticsearch_limit" {
  name = "/bat/${lower(var.environment)}-elasticsearch-limit"
}

data "aws_ssm_parameter" "cnet_ftp_endpoint" {
  name = "/bat/${lower(var.environment)}-cnet-ftp-endpoint"
}

data "aws_ssm_parameter" "cnet_ftp_port" {
  name = "/bat/${lower(var.environment)}-cnet-ftp-port"
}

data "aws_ssm_parameter" "cnet_ftp_username" {
  name = "/bat/${lower(var.environment)}-cnet-ftp-username"
}

data "aws_ssm_parameter" "cnet_ftp_password" {
  name = "/bat/${lower(var.environment)}-cnet-ftp-password"
}

data "aws_ssm_parameter" "logit_application" {
  name = "/bat/${lower(var.environment)}-logit-application"
}

######################################
# CIDR ranges for whitelisting
######################################
data "aws_ssm_parameter" "cidr_blocks_allowed_external_ccs" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-ccs"
}

data "aws_ssm_parameter" "cidr_blocks_allowed_external_spark" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-spark"
}

data "aws_ssm_parameter" "cidr_blocks_allowed_external_cognizant" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-cognizant"
}

locals {
  # Normalised CIDR blocks (accounting for 'none' i.e. "-" as value in SSM parameter)
  cidr_blocks_allowed_external_ccs       = data.aws_ssm_parameter.cidr_blocks_allowed_external_ccs.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_ccs.value) : []
  cidr_blocks_allowed_external_spark     = data.aws_ssm_parameter.cidr_blocks_allowed_external_spark.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_spark.value) : []
  cidr_blocks_allowed_external_cognizant = data.aws_ssm_parameter.cidr_blocks_allowed_external_cognizant.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_cognizant.value) : []
}

data "aws_vpc" "scale" {
  id = data.aws_ssm_parameter.vpc_id.value
}

######################################
# Temporary solution - security groups
# - copy/paste from original
######################################
resource "aws_security_group" "spree" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "app-spree-${lower(var.stage)}"
  description = "Allow inbound db traffic"

  # TODO: Can this be limited to VPC (i.e. via Bastion host in pub subs?)
  ingress {
    description = "SSH from allowed external ranges"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
  }

  ingress {
    description = "HTTP via internal LB"
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.scale.cidr_block]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "client" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "app-client-${lower(var.stage)}"
  description = "Allow inbound db traffic"

  ingress {
    description = "SSH from allowed external ranges"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
  }

  ingress {
    description = "HTTP via external ALB"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.scale.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "s3-virus-scan" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "app-s3-virus-scan-${lower(var.stage)}"
  description = "Allow inbound db traffic"

  ingress {
    from_port   = 4567
    to_port     = 4567
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.scale.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "rds-spree-${lower(var.stage)}"
  description = "Allow inbound db traffic"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.scale.cidr_block]
  }
}

resource "aws_security_group" "redis" {
  name        = "redis-security-group"
  description = "controls access to the redis"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    cidr_blocks = [data.aws_vpc.scale.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "memcached" {
  name        = "memcached-security-group"
  description = "controls access to the redis"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    protocol    = "tcp"
    from_port   = 11211
    to_port     = 11211
    cidr_blocks = [data.aws_vpc.scale.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################################
# Temporary solution - roles
# - copy/paste from original
######################################
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "SCALE_ECS_BAT_Services_Task_Execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_s3" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_read_ssm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

######################################
# Modules
######################################


module "s3" {
  source      = "../../s3"
  stage       = var.stage
  environment = var.environment
}

module "memcached" {
  source                       = "../../memcached"
  aws_account_id               = var.aws_account_id
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_memcached_ids = [aws_security_group.memcached.id]
  security_group_redis_ids     = [aws_security_group.redis.id]
  memcached_node_type          = var.memcached_node_type
  redis_node_type              = var.redis_node_type
  az_names                     = var.az_names
}

module "ecs_client" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  security_group_ids   = [aws_security_group.client.id]
  ec2_instance_type    = var.client_ec2_instance_type
  resource_name_suffix = "CLIENT"
}

module "ecs_spree" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids   = [aws_security_group.spree.id]
  ec2_instance_type    = var.spree_ec2_instance_type
  resource_name_suffix = "SPREE"
}

module "ecs_sidekiq" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids   = [aws_security_group.spree.id]
  ec2_instance_type    = var.sidekiq_ec2_instance_type
  resource_name_suffix = "SIDEKIQ"
}

module "ecs_s3_virus_scan" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids   = [aws_security_group.s3-virus-scan.id]
  ec2_instance_type    = var.s3_virus_scan_ec2_instance_type
  resource_name_suffix = "S3_VIRUS_SCAN"
}

######################################
# Spree Service
######################################

module "spree" {
  source                             = "../../services/spree"
  environment                        = var.environment
  vpc_id                             = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                     = module.ecs_spree.ecs_cluster_id
  lb_public_alb_arn                  = data.aws_ssm_parameter.lb_public_alb_arn.value
  lb_private_nlb_arn                 = data.aws_ssm_parameter.lb_private_arn.value
  hosted_zone_name                   = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
  private_app_subnet_ids             = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn                 = aws_iam_role.ecs_task_execution_role.arn
  app_port                           = "4567"
  cpu                                = var.spree_cpu
  memory                             = var.spree_memory
  aws_region                         = local.aws_region
  db_name                            = local.spree_db_name
  db_host                            = data.aws_ssm_parameter.spree_db_endpoint.value
  db_username                        = data.aws_ssm_parameter.spree_db_username.value
  db_password                        = data.aws_ssm_parameter.spree_db_password.value
  secret_key_base                    = data.aws_ssm_parameter.secret_key_base.value
  rollbar_access_token               = data.aws_ssm_parameter.rollbar_access_token.value
  basicauth_username                 = data.aws_ssm_parameter.basic_auth_username.value
  basicauth_password                 = data.aws_ssm_parameter.basic_auth_password.value
  basicauth_enabled                  = data.aws_ssm_parameter.basic_auth_enabled.value
  products_import_bucket             = data.aws_ssm_parameter.products_import_bucket.value
  rollbar_env                        = var.rollbar_env
  redis_url                          = module.memcached.redis_url
  memcached_endpoint                 = module.memcached.memcached_endpoint
  security_groups                    = [aws_security_group.spree.id]
  env_file                           = module.s3.env_file_spree
  cloudfront_id                      = data.aws_ssm_parameter.bat_backend_cloudfront_id.value
  ecr_image_id_spree                 = var.ecr_image_id_spree
  elasticsearch_url                  = "https://${data.aws_ssm_parameter.elasticsearch_url.value}:443"
  buyer_ui_url                       = "https://${data.aws_ssm_parameter.hosted_zone_name_cdn_bat_client.value}"
  app_domain                         = data.aws_ssm_parameter.hosted_zone_name_cdn_bat_backend.value
  logit_hostname                     = data.aws_ssm_parameter.logit_hostname.value
  logit_remote_port                  = data.aws_ssm_parameter.logit_remote_port.value
  suppliers_sftp_bucket              = data.aws_ssm_parameter.suppliers_sftp_bucket.value
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  lograge_enabled                    = data.aws_ssm_parameter.lograge_enabled.value
  sendgrid_api_key                   = data.aws_ssm_parameter.sendgrid_api_key.value
  mail_from                          = data.aws_ssm_parameter.mail_from.value
  sidekiq_concurrency                = data.aws_ssm_parameter.sidekiq_concurrency.value
  sidekiq_concurrency_searchkick     = data.aws_ssm_parameter.sidekiq_concurrency_searchkick.value
  elasticsearch_limit                = data.aws_ssm_parameter.elasticsearch_limit.value
  cnet_ftp_endpoint                  = data.aws_ssm_parameter.cnet_ftp_endpoint.value
  cnet_ftp_port                      = data.aws_ssm_parameter.cnet_ftp_port.value
  cnet_ftp_username                  = data.aws_ssm_parameter.cnet_ftp_username.value
  cnet_ftp_password                  = data.aws_ssm_parameter.cnet_ftp_password.value
}

######################################
# Sidekiq Service
######################################

module "sidekiq" {
  source                             = "../../services/sidekiq"
  environment                        = var.environment
  vpc_id                             = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                     = module.ecs_sidekiq.ecs_cluster_id
  private_app_subnet_ids             = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn                 = aws_iam_role.ecs_task_execution_role.arn
  app_port                           = "4567"
  cpu                                = var.sidekiq_cpu
  memory                             = var.sidekiq_memory
  aws_region                         = local.aws_region
  db_name                            = local.spree_db_name
  db_host                            = data.aws_ssm_parameter.spree_db_endpoint.value
  db_username                        = data.aws_ssm_parameter.spree_db_username.value
  db_password                        = data.aws_ssm_parameter.spree_db_password.value
  secret_key_base                    = data.aws_ssm_parameter.secret_key_base.value
  rollbar_access_token               = data.aws_ssm_parameter.rollbar_access_token.value
  basicauth_username                 = data.aws_ssm_parameter.basic_auth_username.value
  basicauth_password                 = data.aws_ssm_parameter.basic_auth_password.value
  basicauth_enabled                  = data.aws_ssm_parameter.basic_auth_enabled.value
  products_import_bucket             = data.aws_ssm_parameter.products_import_bucket.value
  rollbar_env                        = var.rollbar_env
  redis_url                          = module.memcached.redis_url
  security_groups                    = [aws_security_group.spree.id]
  env_file                           = module.s3.env_file_spree
  ecr_image_id_spree                 = var.ecr_image_id_spree
  elasticsearch_url                  = "https://${data.aws_ssm_parameter.elasticsearch_url.value}:443"
  buyer_ui_url                       = "https://${data.aws_ssm_parameter.hosted_zone_name_cdn_bat_client.value}"
  app_domain                         = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
  logit_hostname                     = data.aws_ssm_parameter.logit_hostname.value
  logit_remote_port                  = data.aws_ssm_parameter.logit_remote_port.value
  suppliers_sftp_bucket              = data.aws_ssm_parameter.suppliers_sftp_bucket.value
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  lograge_enabled                    = data.aws_ssm_parameter.lograge_enabled.value
  sendgrid_api_key                   = data.aws_ssm_parameter.sendgrid_api_key.value
  mail_from                          = data.aws_ssm_parameter.mail_from.value
  sidekiq_concurrency                = data.aws_ssm_parameter.sidekiq_concurrency.value
  sidekiq_concurrency_searchkick     = data.aws_ssm_parameter.sidekiq_concurrency_searchkick.value
  elasticsearch_limit                = data.aws_ssm_parameter.elasticsearch_limit.value
  cnet_ftp_endpoint                  = data.aws_ssm_parameter.cnet_ftp_endpoint.value
  cnet_ftp_port                      = data.aws_ssm_parameter.cnet_ftp_port.value
  cnet_ftp_username                  = data.aws_ssm_parameter.cnet_ftp_username.value
  cnet_ftp_password                  = data.aws_ssm_parameter.cnet_ftp_password.value
}

######################################
# Client/Buyer UI Service
######################################

module "client" {
  source                             = "../../services/client"
  environment                        = var.environment
  vpc_id                             = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                     = module.ecs_client.ecs_cluster_id
  lb_public_alb_arn                  = data.aws_ssm_parameter.lb_public_alb_arn.value
  hosted_zone_name                   = data.aws_ssm_parameter.hosted_zone_name_alb_bat_client.value
  public_web_subnet_ids              = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  execution_role_arn                 = aws_iam_role.ecs_task_execution_role.arn
  client_app_port                    = "8080" //8080
  client_app_host                    = "0.0.0.0"
  cpu                                = var.client_cpu
  memory                             = var.client_memory
  aws_region                         = local.aws_region
  rollbar_access_token               = data.aws_ssm_parameter.rollbar_access_token.value
  basicauth_username                 = data.aws_ssm_parameter.basic_auth_username.value
  basicauth_password                 = data.aws_ssm_parameter.basic_auth_password.value
  basicauth_enabled                  = data.aws_ssm_parameter.basic_auth_enabled.value
  client_session_secret              = data.aws_ssm_parameter.client_session_secret.value
  security_groups                    = [aws_security_group.client.id]
  env_file                           = module.s3.env_file_client
  cloudfront_id                      = data.aws_ssm_parameter.bat_client_cloudfront_id.value
  spree_api_host                     = "http://${data.aws_ssm_parameter.lb_private_dns.value}"
  spree_image_host                   = "https://${data.aws_ssm_parameter.hosted_zone_name_cdn_bat_backend.value}"
  rollbar_env                        = var.rollbar_env
  ecr_image_id_client                = var.ecr_image_id_client
  logit_hostname                     = data.aws_ssm_parameter.logit_hostname.value
  logit_remote_port                  = data.aws_ssm_parameter.logit_remote_port.value
  documents_terms_and_conditions_url = data.aws_ssm_parameter.documents_terms_and_conditions_url.value
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  logit_node                         = data.aws_ssm_parameter.logit_node.value
  browser_rollbar_access_token       = data.aws_ssm_parameter.browser_rollbar_access_token.value
  enable_basket                      = data.aws_ssm_parameter.enable_basket.value
  enable_quotes                      = data.aws_ssm_parameter.enable_quotes.value
  logit_application                  = data.aws_ssm_parameter.logit_application.value
}

######################################
# S3 Virus scan Service
######################################

module "s3_virus_scan" {
  source                             = "../../services/s3-virus-scan"
  environment                        = var.environment
  vpc_id                             = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                     = module.ecs_s3_virus_scan.ecs_cluster_id
  lb_private_nlb_arn                 = data.aws_ssm_parameter.lb_private_arn.value
  private_app_subnet_ids             = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn                 = aws_iam_role.ecs_task_execution_role.arn
  app_port                           = "4567"
  cpu                                = var.s3_virus_scan_cpu
  memory                             = var.s3_virus_scan_memory
  ecr_image_id_s3_virus_scan         = var.ecr_image_id_s3_virus_scan
  aws_region                         = local.aws_region
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  security_groups                    = [aws_security_group.s3-virus-scan.id]
  aws_access_key_id                  = data.aws_ssm_parameter.aws_access_key_id.arn
  aws_secret_access_key              = data.aws_ssm_parameter.aws_secret_access_key.arn
  host                               = "http://${data.aws_ssm_parameter.lb_private_dns.value}:4567"
  stage                              = var.stage
  cidr_blocks                        = [data.aws_vpc.scale.cidr_block]
}
