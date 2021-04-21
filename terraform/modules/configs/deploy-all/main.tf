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
  aws_region            = "eu-west-2"
  spree_db_name         = "spree"
  suppliers_sftp_bucket = "scale-${lower(var.environment)}-s3-aws-sftp"
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

data "aws_ssm_parameter" "elasticsearch_url" {
  name = "/bat/${lower(var.environment)}-elasticsearch-url"
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

data "aws_ssm_parameter" "client_session_secret" {
  name = "/bat/${lower(var.environment)}-session-cookie-secret"
}

data "aws_ssm_parameter" "spree_db_username" {
  name            = "/bat/${lower(var.environment)}-spree-db-app-username"
  with_decryption = true
}

data "aws_ssm_parameter" "spree_db_password" {
  name            = "/bat/${lower(var.environment)}-spree-db-app-password"
  with_decryption = true
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

data "aws_ssm_parameter" "sendgrid_api_key" {
  name = "/bat/${lower(var.environment)}-sendgrid-api-key"
}

data "aws_ssm_parameter" "browser_rollbar_access_token" {
  name = "/bat/${lower(var.environment)}-browser-rollbar-access-token"
}

data "aws_ssm_parameter" "lb_public_alb_arn" {
  name = "${lower(var.environment)}-lb-public-alb-arn"
}

data "aws_ssm_parameter" "cnet_ftp_username" {
  name = "/bat/${lower(var.environment)}-cnet-ftp-username"
}

data "aws_ssm_parameter" "cnet_ftp_password" {
  name = "/bat/${lower(var.environment)}-cnet-ftp-password"
}

data "aws_ssm_parameter" "logit_hostname" {
  name = "/bat/${lower(var.environment)}-logit-hostname"
}

data "aws_ssm_parameter" "logit_remote_port" {
  name = "/bat/${lower(var.environment)}-logit-remote-port"
}

data "aws_ssm_parameter" "logit_node" {
  name = "/bat/${lower(var.environment)}-logit-node"
}

data "aws_ssm_parameter" "sidekiq_username" {
  name = "/bat/${lower(var.environment)}-sidekiq-username"
}

data "aws_ssm_parameter" "sidekiq_password" {
  name = "/bat/${lower(var.environment)}-sidekiq-password"
}

data "aws_ssm_parameter" "sendgrid_username" {
  name = "/bat/${lower(var.environment)}-sendgrid-username"
}

data "aws_ssm_parameter" "sendgrid_password" {
  name = "/bat/${lower(var.environment)}-sendgrid-password"
}

data "aws_ssm_parameter" "new_relic_license_key" {
  name = "/bat/${lower(var.environment)}-new-relic-license-key"
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

data "aws_ssm_parameter" "cidr_block_vpc" {
  name = "${lower(var.environment)}-cidr-block-vpc"
}

data "aws_ssm_parameter" "cidr_blocks_allowed_external_api_gateway" {
  name = "${lower(var.environment)}-cidr-blocks-allowed-external-api-gateway"
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

# Get the public IP values for NAT/GW to add to the API gateway allowed list
data "aws_ssm_parameter" "nat_eip_ids" {
  name = "${lower(var.environment)}-eip-ids-nat-gateway"
}

data "aws_eip" "nat_eips" {
  for_each = toset(split(",", data.aws_ssm_parameter.nat_eip_ids.value))

  id = each.key
}

locals {
  # Normalised CIDR blocks (accounting for 'none' i.e. "-" as value in SSM parameter)
  cidr_blocks_allowed_external_api_gateway = data.aws_ssm_parameter.cidr_blocks_allowed_external_api_gateway.value != "-" ? split(",", data.aws_ssm_parameter.cidr_blocks_allowed_external_api_gateway.value) : []
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

data "aws_ssm_parameter" "kms_id_ssm" {
  name = "${lower(var.environment)}-ssm-encryption-key"
}

resource "aws_iam_policy" "kms_decrypt_ssm_cmk" {
  name_prefix = "KMS_Decrypt_SSM_CMK"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
        ]
        Resource = "${data.aws_ssm_parameter.kms_id_ssm.value}"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_kms_decrypt_ssm_cmk" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.kms_decrypt_ssm_cmk.arn
}

######################################
# Modules
######################################

module "s3" {
  source                          = "../../s3"
  stage                           = var.stage
  environment                     = var.environment
  s3_noncurrent_retention_in_days = var.s3_noncurrent_retention_in_days
  s3_force_destroy                = var.s3_force_destroy
}

module "iam" {
  source                   = "../../iam"
  environment              = var.environment
  spree_bucket_access_arns = [module.s3.s3_static_bucket_arn, module.s3.s3_cnet_bucket_arn, module.s3.s3_product_import_bucket_arn]
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
  dev_user_public_key  = var.dev_user_public_key
}

module "ecs_spree" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids   = [aws_security_group.spree.id]
  ec2_instance_type    = var.spree_ec2_instance_type
  resource_name_suffix = "SPREE"
  dev_user_public_key  = var.dev_user_public_key
}

module "ecs_sidekiq" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids   = [aws_security_group.spree.id]
  ec2_instance_type    = var.sidekiq_ec2_instance_type
  resource_name_suffix = "SIDEKIQ"
  dev_user_public_key  = var.dev_user_public_key
}

module "ecs_s3_virus_scan" {
  source               = "../../ecs"
  environment          = var.environment
  subnet_ids           = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids   = [aws_security_group.s3-virus-scan.id]
  ec2_instance_type    = var.s3_virus_scan_ec2_instance_type
  resource_name_suffix = "S3_VIRUS_SCAN"
  dev_user_public_key  = var.dev_user_public_key
}

module "ecs_fargate" {
  source         = "../../ecs-fargate"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  environment    = var.environment
  cidr_block_vpc = data.aws_ssm_parameter.cidr_block_vpc.value
}

######################################
# Spree Service
######################################

module "spree" {
  source                                             = "../../services/spree"
  environment                                        = var.environment
  vpc_id                                             = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                                     = module.ecs_spree.ecs_cluster_id
  lb_public_alb_arn                                  = data.aws_ssm_parameter.lb_public_alb_arn.value
  lb_private_nlb_arn                                 = data.aws_ssm_parameter.lb_private_arn.value
  hosted_zone_name                                   = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
  private_app_subnet_ids                             = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn                                 = aws_iam_role.ecs_task_execution_role.arn
  app_port                                           = "4567"
  cpu                                                = var.spree_cpu
  memory                                             = var.spree_memory
  aws_region                                         = local.aws_region
  db_name                                            = local.spree_db_name
  db_host                                            = data.aws_ssm_parameter.spree_db_endpoint.value
  basicauth_enabled                                  = var.basic_auth_enabled
  products_import_bucket                             = module.s3.s3_product_import_name
  rollbar_env                                        = var.rollbar_env
  redis_url                                          = module.memcached.redis_url
  memcached_endpoint                                 = module.memcached.memcached_endpoint
  security_groups                                    = [aws_security_group.spree.id]
  cloudfront_id                                      = data.aws_ssm_parameter.bat_backend_cloudfront_id.value
  ecr_image_id_spree                                 = var.ecr_image_id_spree
  elasticsearch_url                                  = "https://${data.aws_ssm_parameter.elasticsearch_url.value}:443"
  buyer_ui_url                                       = "https://${data.aws_ssm_parameter.hosted_zone_name_cdn_bat_client.value}"
  app_domain                                         = data.aws_ssm_parameter.hosted_zone_name_cdn_bat_backend.value
  suppliers_sftp_bucket                              = local.suppliers_sftp_bucket
  deployment_maximum_percent                         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent                 = var.deployment_minimum_healthy_percent
  lograge_enabled                                    = var.lograge_enabled
  mail_from                                          = var.email_from
  sidekiq_concurrency                                = var.sidekiq_concurrency
  sidekiq_concurrency_searchkick                     = var.sidekiq_concurrency_searchkick
  elasticsearch_limit                                = var.elasticsearch_limit
  cnet_ftp_endpoint                                  = var.cnet_ftp_endpoint
  cnet_ftp_port                                      = var.cnet_ftp_port
  s3_static_bucket_name                              = module.s3.s3_static_bucket_name
  new_relic_app_name                                 = var.new_relic_app_name == null ? "BaT Spree ${upper(var.environment)}" : var.new_relic_app_name
  new_relic_agent_enabled                            = var.new_relic_agent_enabled
  default_country_id                                 = var.default_country_id
  buyer_organizations_import_bucket                  = module.s3.s3_product_import_name
  cnet_products_import_bucket                        = module.s3.s3_cnet_import_bucket_name
  cnet_products_import_updates_dir                   = var.cnet_products_import_updates_dir
  sidekiq_concurrency_catalog_reindex                = var.sidekiq_concurrency_catalog_reindex
  sidekiq_concurrency_cnet_import_feed               = var.sidekiq_concurrency_cnet_import_feed
  sidekiq_concurrency_cnet_import_categories         = var.sidekiq_concurrency_cnet_import_categories
  sidekiq_concurrency_cnet_import_documents          = var.sidekiq_concurrency_cnet_import_documents
  sidekiq_concurrency_cnet_import_images             = var.sidekiq_concurrency_cnet_import_images
  sidekiq_concurrency_cnet_import_properties         = var.sidekiq_concurrency_cnet_import_properties
  sidekiq_concurrency_cnet_import_xmls               = var.sidekiq_concurrency_cnet_import_xmls
  sidekiq_concurrency_cnet_import_missing_properties = var.sidekiq_concurrency_cnet_import_missing_properties
  sidekiq_concurrency_cnet_import_missing_xmls       = var.sidekiq_concurrency_cnet_import_missing_xmls
  rack_timeout_service_timeout                       = var.rack_timeout_service_timeout
  enable_admin_panel_orders                          = var.enable_admin_panel_orders
  ecs_log_retention_in_days                          = var.ecs_log_retention_in_days

  # Secrets
  aws_access_key_id_ssm_arn     = module.iam.aws_access_key_id_ssm_arn
  aws_secret_access_key_ssm_arn = module.iam.aws_secret_access_key_ssm_arn
  basicauth_username_ssm_arn    = data.aws_ssm_parameter.basic_auth_username.arn
  basicauth_password_ssm_arn    = data.aws_ssm_parameter.basic_auth_password.arn
  cnet_ftp_username_ssm_arn     = data.aws_ssm_parameter.cnet_ftp_username.arn
  cnet_ftp_password_ssm_arn     = data.aws_ssm_parameter.cnet_ftp_password.arn
  db_username_ssm_arn           = data.aws_ssm_parameter.spree_db_username.arn
  db_password_ssm_arn           = data.aws_ssm_parameter.spree_db_password.arn
  logit_hostname_ssm_arn        = data.aws_ssm_parameter.logit_hostname.arn
  logit_remote_port_ssm_arn     = data.aws_ssm_parameter.logit_remote_port.arn
  new_relic_license_key_ssm_arn = data.aws_ssm_parameter.new_relic_license_key.arn
  rollbar_access_token_ssm_arn  = data.aws_ssm_parameter.rollbar_access_token.arn
  secret_key_base_ssm_arn       = data.aws_ssm_parameter.secret_key_base.arn
  sendgrid_username_ssm_arn     = data.aws_ssm_parameter.sendgrid_username.arn
  sendgrid_password_ssm_arn     = data.aws_ssm_parameter.sendgrid_password.arn
  sendgrid_api_key_ssm_arn      = data.aws_ssm_parameter.sendgrid_api_key.arn
  sidekiq_username_ssm_arn      = data.aws_ssm_parameter.sidekiq_username.arn
  sidekiq_password_ssm_arn      = data.aws_ssm_parameter.sidekiq_password.arn
}

######################################
# Sidekiq Service
######################################

module "sidekiq" {
  source                                             = "../../services/sidekiq"
  environment                                        = var.environment
  vpc_id                                             = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                                     = module.ecs_sidekiq.ecs_cluster_id
  private_app_subnet_ids                             = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn                                 = aws_iam_role.ecs_task_execution_role.arn
  app_port                                           = "4567"
  cpu                                                = var.sidekiq_cpu
  memory                                             = var.sidekiq_memory
  aws_region                                         = local.aws_region
  db_name                                            = local.spree_db_name
  db_host                                            = data.aws_ssm_parameter.spree_db_endpoint.value
  basicauth_enabled                                  = var.basic_auth_enabled
  products_import_bucket                             = module.s3.s3_product_import_name
  rollbar_env                                        = var.rollbar_env
  redis_url                                          = module.memcached.redis_url
  security_groups                                    = [aws_security_group.spree.id]
  ecr_image_id_spree                                 = var.ecr_image_id_spree
  elasticsearch_url                                  = "https://${data.aws_ssm_parameter.elasticsearch_url.value}:443"
  buyer_ui_url                                       = "https://${data.aws_ssm_parameter.hosted_zone_name_cdn_bat_client.value}"
  app_domain                                         = data.aws_ssm_parameter.hosted_zone_name_cdn_bat_backend.value
  suppliers_sftp_bucket                              = local.suppliers_sftp_bucket
  deployment_maximum_percent                         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent                 = var.deployment_minimum_healthy_percent
  lograge_enabled                                    = var.lograge_enabled
  mail_from                                          = var.email_from
  sidekiq_concurrency                                = var.sidekiq_concurrency
  sidekiq_concurrency_searchkick                     = var.sidekiq_concurrency_searchkick
  elasticsearch_limit                                = var.elasticsearch_limit
  cnet_ftp_endpoint                                  = var.cnet_ftp_endpoint
  cnet_ftp_port                                      = var.cnet_ftp_port
  s3_static_bucket_name                              = module.s3.s3_static_bucket_name
  new_relic_app_name                                 = var.new_relic_app_name == null ? "BaT Spree ${upper(var.environment)}" : var.new_relic_app_name
  new_relic_agent_enabled                            = var.new_relic_agent_enabled
  default_country_id                                 = var.default_country_id
  buyer_organizations_import_bucket                  = module.s3.s3_product_import_name
  cnet_products_import_bucket                        = module.s3.s3_cnet_import_bucket_name
  cnet_products_import_updates_dir                   = var.cnet_products_import_updates_dir
  sidekiq_concurrency_catalog_reindex                = var.sidekiq_concurrency_catalog_reindex
  sidekiq_concurrency_cnet_import_feed               = var.sidekiq_concurrency_cnet_import_feed
  sidekiq_concurrency_cnet_import_categories         = var.sidekiq_concurrency_cnet_import_categories
  sidekiq_concurrency_cnet_import_documents          = var.sidekiq_concurrency_cnet_import_documents
  sidekiq_concurrency_cnet_import_images             = var.sidekiq_concurrency_cnet_import_images
  sidekiq_concurrency_cnet_import_properties         = var.sidekiq_concurrency_cnet_import_properties
  sidekiq_concurrency_cnet_import_xmls               = var.sidekiq_concurrency_cnet_import_xmls
  sidekiq_concurrency_cnet_import_missing_properties = var.sidekiq_concurrency_cnet_import_missing_properties
  sidekiq_concurrency_cnet_import_missing_xmls       = var.sidekiq_concurrency_cnet_import_missing_xmls
  rack_timeout_service_timeout                       = var.rack_timeout_service_timeout
  enable_admin_panel_orders                          = var.enable_admin_panel_orders
  ecs_log_retention_in_days                          = var.ecs_log_retention_in_days

  # Secrets
  aws_access_key_id_ssm_arn     = module.iam.aws_access_key_id_ssm_arn
  aws_secret_access_key_ssm_arn = module.iam.aws_secret_access_key_ssm_arn
  basicauth_username_ssm_arn    = data.aws_ssm_parameter.basic_auth_username.arn
  basicauth_password_ssm_arn    = data.aws_ssm_parameter.basic_auth_password.arn
  cnet_ftp_username_ssm_arn     = data.aws_ssm_parameter.cnet_ftp_username.arn
  cnet_ftp_password_ssm_arn     = data.aws_ssm_parameter.cnet_ftp_password.arn
  db_username_ssm_arn           = data.aws_ssm_parameter.spree_db_username.arn
  db_password_ssm_arn           = data.aws_ssm_parameter.spree_db_password.arn
  logit_hostname_ssm_arn        = data.aws_ssm_parameter.logit_hostname.arn
  logit_remote_port_ssm_arn     = data.aws_ssm_parameter.logit_remote_port.arn
  new_relic_license_key_ssm_arn = data.aws_ssm_parameter.new_relic_license_key.arn
  rollbar_access_token_ssm_arn  = data.aws_ssm_parameter.rollbar_access_token.arn
  secret_key_base_ssm_arn       = data.aws_ssm_parameter.secret_key_base.arn
  sendgrid_username_ssm_arn     = data.aws_ssm_parameter.sendgrid_username.arn
  sendgrid_password_ssm_arn     = data.aws_ssm_parameter.sendgrid_password.arn
  sendgrid_api_key_ssm_arn      = data.aws_ssm_parameter.sendgrid_api_key.arn
  sidekiq_username_ssm_arn      = data.aws_ssm_parameter.sidekiq_username.arn
  sidekiq_password_ssm_arn      = data.aws_ssm_parameter.sidekiq_password.arn
}

######################################
# Client/Buyer UI Service
######################################

module "client" {
  source                               = "../../services/client"
  environment                          = var.environment
  vpc_id                               = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id                       = module.ecs_client.ecs_cluster_id
  lb_public_alb_arn                    = data.aws_ssm_parameter.lb_public_alb_arn.value
  hosted_zone_name                     = data.aws_ssm_parameter.hosted_zone_name_alb_bat_client.value
  public_web_subnet_ids                = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  execution_role_arn                   = aws_iam_role.ecs_task_execution_role.arn
  client_app_port                      = "8080" //8080
  client_app_host                      = "0.0.0.0"
  cpu                                  = var.client_cpu
  memory                               = var.client_memory
  aws_region                           = local.aws_region
  basicauth_enabled                    = var.basic_auth_enabled
  security_groups                      = [aws_security_group.client.id]
  cloudfront_id                        = data.aws_ssm_parameter.bat_client_cloudfront_id.value
  spree_api_host                       = "http://${data.aws_ssm_parameter.lb_private_dns.value}"
  spree_image_host                     = "https://${data.aws_ssm_parameter.hosted_zone_name_cdn_bat_backend.value}"
  rollbar_env                          = var.rollbar_env
  ecr_image_id_client                  = var.ecr_image_id_client
  documents_terms_and_conditions_url   = var.documents_terms_and_conditions_url
  deployment_maximum_percent           = var.deployment_maximum_percent
  deployment_minimum_healthy_percent   = var.deployment_minimum_healthy_percent
  enable_basket                        = var.enable_basket
  enable_quotes                        = var.enable_quotes
  enable_ordering                      = var.enable_ordering
  logit_application                    = var.logit_application == null ? "BAT-Buyer-UI-${upper(var.environment)}" : var.logit_application
  error_pages_unknonwn_server_endpoint = var.error_pages_unknonwn_server_endpoint
  ecs_log_retention_in_days            = var.ecs_log_retention_in_days
  # Secrets
  browser_rollbar_access_token_ssm_arn = data.aws_ssm_parameter.browser_rollbar_access_token.arn
  rollbar_access_token_ssm_arn         = data.aws_ssm_parameter.rollbar_access_token.arn
  basicauth_username_ssm_arn           = data.aws_ssm_parameter.basic_auth_username.arn
  basicauth_password_ssm_arn           = data.aws_ssm_parameter.basic_auth_password.arn
  client_session_secret_ssm_arn        = data.aws_ssm_parameter.client_session_secret.arn
  logit_hostname_ssm_arn               = data.aws_ssm_parameter.logit_hostname.arn
  logit_remote_port_ssm_arn            = data.aws_ssm_parameter.logit_remote_port.arn
  logit_node_ssm_arn                   = data.aws_ssm_parameter.logit_node.arn
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
  aws_access_key_id                  = module.iam.aws_access_key_id_ssm_arn
  aws_secret_access_key              = module.iam.aws_secret_access_key_ssm_arn
  host                               = "http://${data.aws_ssm_parameter.lb_private_dns.value}:4567"
  stage                              = var.stage
  cidr_blocks                        = [data.aws_vpc.scale.cidr_block]
  ecs_log_retention_in_days          = var.ecs_log_retention_in_days
}

######################################
# API Gateway
######################################

module "api" {
  source      = "../../api"
  environment = var.environment

  # Allow traffic from VPC, NAT and environment specific CIDR ranges (e.g. CCS, CCS web infra etc)
  cidr_blocks_allowed_external_api_gateway = concat(tolist([data.aws_ssm_parameter.cidr_block_vpc.value]), values(data.aws_eip.nat_eips)[*].public_ip, local.cidr_blocks_allowed_external_api_gateway)
}


######################################
# Catalogue Service API
######################################

module "catalogue" {
  source                       = "../../services/catalogue"
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids        = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                  = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn               = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns               = data.aws_ssm_parameter.lb_private_dns.value
  scale_rest_api_id            = module.api.scale_rest_api_id
  scale_rest_api_execution_arn = module.api.scale_rest_api_execution_arn
  parent_resource_id           = module.api.parent_resource_id
  ecs_security_group_id        = module.ecs_fargate.ecs_security_group_id
  ecs_task_execution_arn       = module.ecs_fargate.ecs_task_execution_arn
  ecs_cluster_id               = module.ecs_fargate.ecs_cluster_id
  catalogue_cpu                = var.catalogue_cpu
  catalogue_memory             = var.catalogue_memory
  ecr_image_id_catalogue       = var.ecr_image_id_catalogue
  ecs_log_retention_in_days    = var.ecs_log_retention_in_days
  spree_api_host               = "http://${data.aws_ssm_parameter.lb_private_dns.value}"
}

######################################
# Auth Service API
######################################

module "auth" {
  source                       = "../../services/auth"
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  private_db_subnet_ids        = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  vpc_link_id                  = data.aws_ssm_parameter.vpc_link_id.value
  lb_private_arn               = data.aws_ssm_parameter.lb_private_arn.value
  lb_private_dns               = data.aws_ssm_parameter.lb_private_dns.value
  scale_rest_api_id            = module.api.scale_rest_api_id
  scale_rest_api_execution_arn = module.api.scale_rest_api_execution_arn
  parent_resource_id           = module.api.parent_resource_id
  ecs_security_group_id        = module.ecs_fargate.ecs_security_group_id
  ecs_task_execution_arn       = module.ecs_fargate.ecs_task_execution_arn
  ecs_cluster_id               = module.ecs_fargate.ecs_cluster_id
  auth_cpu                     = var.auth_cpu
  auth_memory                  = var.auth_memory
  ecr_image_id_auth            = var.ecr_image_id_auth
  ecs_log_retention_in_days    = var.ecs_log_retention_in_days
  spree_api_host               = "http://${data.aws_ssm_parameter.lb_private_dns.value}"
}

module "api-deployment" {
  source                       = "../../services/api-deployment"
  environment                  = var.environment
  scale_rest_api_id            = module.api.scale_rest_api_id
  api_rate_limit               = var.api_rate_limit
  api_burst_limit              = var.api_burst_limit
  api_gw_log_retention_in_days = var.api_gw_log_retention_in_days
  scale_rest_api_policy_json   = module.api.scale_rest_api_policy_json

  // Simulate depends_on:
  catalogue_api_gateway_integration = module.catalogue.catalogue_api_gateway_integration
  auth_api_gateway_integration      = module.auth.auth_api_gateway_integration
}
