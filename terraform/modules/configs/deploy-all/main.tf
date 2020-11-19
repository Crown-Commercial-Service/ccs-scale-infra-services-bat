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

data "aws_ssm_parameter" "cloudfront_id" {
  name = "${lower(var.environment)}-cloudfront-id"
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

data "aws_ssm_parameter" "papertrail_hostname" {
  name = "/bat/${lower(var.environment)}-papertrail-hostname"
}

data "aws_ssm_parameter" "papertrail_remote_port" {
  name = "/bat/${lower(var.environment)}-papertrail-remote-port"
}

data "aws_ssm_parameter" "hosted_zone_name_alb_bat_client" {
  name = "/bat/${lower(var.environment)}-hosted-zone-name-alb-bat-client"
}

data "aws_ssm_parameter" "hosted_zone_name_alb_bat_backend" {
  name = "/bat/${lower(var.environment)}-hosted-zone-name-alb-bat-backend"
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
}
resource "aws_security_group_rule" "spree-allow-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
}
resource "aws_security_group_rule" "spree-allow-http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = [data.aws_vpc.scale.cidr_block] # Load balancer only (from client)
}
resource "aws_security_group_rule" "spree-allow-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
}

resource "aws_security_group_rule" "spree-test" {
  type              = "ingress"
  from_port         = 4567
  to_port           = 4567
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = [data.aws_vpc.scale.cidr_block]
}

resource "aws_security_group_rule" "spree-es" {
  type              = "ingress"
  from_port         = 9200
  to_port           = 9200
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = [data.aws_vpc.scale.cidr_block]
}

resource "aws_security_group_rule" "spree-allow-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "client" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "app-client-${lower(var.stage)}"
  description = "Allow inbound db traffic"
}
resource "aws_security_group_rule" "client-allow-ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.client.id
  cidr_blocks       = concat(local.cidr_blocks_allowed_external_ccs, local.cidr_blocks_allowed_external_spark, tolist([data.aws_vpc.scale.cidr_block]))
}
resource "aws_security_group_rule" "client-allow-http-internal" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.client.id
  cidr_blocks       = [data.aws_vpc.scale.cidr_block]
}

resource "aws_security_group_rule" "client-allow-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.client.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "client-allow-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.client.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group" "rds" {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  name        = "rds-spree-${lower(var.stage)}"
  description = "Allow inbound db traffic"
}
resource "aws_security_group_rule" "rds-allow-psql" {
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = [data.aws_vpc.scale.cidr_block]
}
resource "aws_security_group_rule" "rds-allow-outgoing" {
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = [data.aws_vpc.scale.cidr_block]
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
  environment                  = var.environment
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_memcached_ids = [aws_security_group.memcached.id]
  security_group_redis_ids     = [aws_security_group.redis.id]
}

module "ecs" {
  source                = "../../ecs"
  environment           = var.environment
  public_web_subnet_ids = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  security_group_ids    = [aws_security_group.client.id]
}

module "load_balancer_spree" {
  source                = "../../load-balancer"
  environment           = var.environment
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  lb_suffix             = "spree"
  public_web_subnet_ids = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  hosted_zone_name      = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
}

module "load_balancer_client" {
  source                = "../../load-balancer"
  environment           = var.environment
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  lb_suffix             = "client"
  public_web_subnet_ids = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  hosted_zone_name      = data.aws_ssm_parameter.hosted_zone_name_alb_bat_client.value
}

######################################
# Spree Service
######################################

module "spree" {
  source                 = "../../services/spree"
  environment            = var.environment
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  lb_public_alb_arn      = module.load_balancer_spree.lb_public_alb_arn
  lb_public_alb_dns      = module.load_balancer_spree.lb_public_alb_dns
  lb_private_nlb_arn     = data.aws_ssm_parameter.lb_private_arn.value
  hosted_zone_name       = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
  private_app_subnet_ids = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  app_port               = "4567"
  cpu                    = 512
  memory                 = 2048
  aws_region             = local.aws_region
  db_name                = local.spree_db_name
  db_host                = data.aws_ssm_parameter.spree_db_endpoint.value
  db_username            = data.aws_ssm_parameter.spree_db_username.value
  db_password            = data.aws_ssm_parameter.spree_db_password.value
  secret_key_base        = data.aws_ssm_parameter.secret_key_base.value
  rollbar_access_token   = data.aws_ssm_parameter.rollbar_access_token.value
  basicauth_username     = data.aws_ssm_parameter.basic_auth_username.value
  basicauth_password     = data.aws_ssm_parameter.basic_auth_password.value
  basicauth_enabled      = data.aws_ssm_parameter.basic_auth_enabled.value
  products_import_bucket = data.aws_ssm_parameter.products_import_bucket.value
  rollbar_env            = var.rollbar_env
  redis_url              = module.memcached.redis_url
  memcached_endpoint     = module.memcached.memcached_endpoint
  security_groups        = [aws_security_group.spree.id]
  env_file               = module.s3.env_file_spree
  cloudfront_id          = data.aws_ssm_parameter.cloudfront_id.value
  ecr_image_id_spree     = var.ecr_image_id_spree
  elasticsearch_url      = "https://${data.aws_ssm_parameter.elasticsearch_url.value}:443"
  buyer_ui_url           = "https://${module.load_balancer_client.lb_public_alb_dns}"
  app_domain             = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
  papertrail_hostname    = data.aws_ssm_parameter.papertrail_hostname.value
  papertrail_remote_port = data.aws_ssm_parameter.papertrail_remote_port.value
}

######################################
# Sidekiq Service
######################################

module "sidekiq" {
  source                 = "../../services/sidekiq"
  environment            = var.environment
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  private_app_subnet_ids = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  app_port               = "4567"
  cpu                    = 512
  memory                 = 2048
  aws_region             = local.aws_region
  db_name                = local.spree_db_name
  db_host                = data.aws_ssm_parameter.spree_db_endpoint.value
  db_username            = data.aws_ssm_parameter.spree_db_username.value
  db_password            = data.aws_ssm_parameter.spree_db_password.value
  secret_key_base        = data.aws_ssm_parameter.secret_key_base.value
  rollbar_access_token   = data.aws_ssm_parameter.rollbar_access_token.value
  basicauth_username     = data.aws_ssm_parameter.basic_auth_username.value
  basicauth_password     = data.aws_ssm_parameter.basic_auth_password.value
  basicauth_enabled      = data.aws_ssm_parameter.basic_auth_enabled.value
  products_import_bucket = data.aws_ssm_parameter.products_import_bucket.value
  rollbar_env            = var.rollbar_env
  redis_url              = module.memcached.redis_url
  security_groups        = [aws_security_group.spree.id]
  env_file               = module.s3.env_file_spree
  ecr_image_id_spree     = var.ecr_image_id_spree
  elasticsearch_url      = "https://${data.aws_ssm_parameter.elasticsearch_url.value}:443"
  buyer_ui_url           = "https://${module.load_balancer_client.lb_public_alb_dns}"
  app_domain             = data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value
  papertrail_hostname    = data.aws_ssm_parameter.papertrail_hostname.value
  papertrail_remote_port = data.aws_ssm_parameter.papertrail_remote_port.value
}

######################################
# Client/Buyer UI Service
######################################

module "client" {
  source                 = "../../services/client"
  environment            = var.environment
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  lb_public_alb_arn      = module.load_balancer_client.lb_public_alb_arn
  hosted_zone_name       = data.aws_ssm_parameter.hosted_zone_name_alb_bat_client.value
  public_web_subnet_ids  = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  client_app_port        = "8080" //8080
  client_app_host        = "0.0.0.0"
  client_cpu             = 256
  client_memory          = 512
  aws_region             = local.aws_region
  rollbar_access_token   = data.aws_ssm_parameter.rollbar_access_token.value
  basicauth_username     = data.aws_ssm_parameter.basic_auth_username.value
  basicauth_password     = data.aws_ssm_parameter.basic_auth_password.value
  basicauth_enabled      = data.aws_ssm_parameter.basic_auth_enabled.value
  client_session_secret  = data.aws_ssm_parameter.client_session_secret.value
  security_groups        = [aws_security_group.client.id]
  env_file               = module.s3.env_file_client
  cloudfront_id          = data.aws_ssm_parameter.cloudfront_id.value
  spree_api_host         = "http://${data.aws_ssm_parameter.lb_private_dns.value}"
  spree_image_host       = "https://${data.aws_ssm_parameter.hosted_zone_name_alb_bat_backend.value}"
  rollbar_env            = var.rollbar_env
  ecr_image_id_client    = var.ecr_image_id_client
  papertrail_hostname    = data.aws_ssm_parameter.papertrail_hostname.value
  papertrail_remote_port = data.aws_ssm_parameter.papertrail_remote_port.value
}
