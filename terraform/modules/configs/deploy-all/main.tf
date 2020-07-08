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

data "aws_ssm_parameter" "lb_public_arn" {
  name = "${lower(var.environment)}-lb-public-arn"
}

data "aws_ssm_parameter" "lb_private_arn" {
  name = "${lower(var.environment)}-lb-private-arn"
}

data "aws_ssm_parameter" "lb_private_dns" {
  name = "${lower(var.environment)}-lb-private-dns"
}


######################################
# Temporary solution - logs
# - copy/paste from original
######################################
resource "aws_cloudwatch_log_group" "cb_log_group" {
  name              = "/ecs/cb-app"
  retention_in_days = 30

  tags = {
    Name = "cb-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "cb-log-stream"
  log_group_name = aws_cloudwatch_log_group.cb_log_group.name
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
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "spree-allow-http" {
  type = "ingress"
  //from_port         = 80
  //to_port           = 80
  from_port         = 8081
  to_port           = 8081
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "spree-allow-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "spree-allow-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.spree.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "spree-test" {
  type = "ingress"
  //from_port         = 80
  //to_port           = 80
  from_port         = 4567
  to_port           = 4567
  protocol          = "tcp"
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
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "client-allow-http" {
  type = "ingress"
  //from_port         = 80
  //to_port           = 80
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.client.id
  cidr_blocks       = ["0.0.0.0/0"]
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
  #source_security_group_id = aws_security_group.spree.id
  #temporarily modified to allow access via bastion host
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "rds-allow-outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.rds.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group" "redis" {
  name        = "redis-security-group"
  description = "controls access to the redis"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  ingress {
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    cidr_blocks = ["0.0.0.0/0"]
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "es" {
  name   = "elasticsearch"
  vpc_id = data.aws_ssm_parameter.vpc_id.value

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

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
  name               = "ECSTaskExecutionRole"
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

module "elasticsearch" {
  source                 = "../../elasticsearch"
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_ids     = [aws_security_group.es.id]
}

module "memcached" {
  source                       = "../../memcached"
  vpc_id                       = data.aws_ssm_parameter.vpc_id.value
  private_app_subnet_ids       = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  security_group_memcached_ids = [aws_security_group.memcached.id]
  security_group_redis_ids     = [aws_security_group.redis.id]
}

module "postgres" {
  source                = "../../postgres"
  stage                 = var.stage
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  db_password           = "testing123"
  private_db_subnet_ids = split(",", data.aws_ssm_parameter.private_db_subnet_ids.value)
  security_group_ids    = [aws_security_group.rds.id]
}

module "ecs" {
  source                = "../../ecs"
  public_web_subnet_ids = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  security_group_ids    = [aws_security_group.client.id]
}

/*
module "api" {
  source      = "../../api"
  environment = var.environment
}
*/

######################################
# Spree Service
######################################

module "spree" {
  source                 = "../../services/spree"
  environment            = var.environment
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  lb_public_arn          = data.aws_ssm_parameter.lb_public_arn.value
  private_app_subnet_ids = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  app_port               = "4567"
  cpu                    = 512
  memory                 = 2048
  aws_region             = "eu-west-2"
  db_name                = module.postgres.db_name
  db_host                = module.postgres.db_host
  db_username            = module.postgres.db_username
  db_password            = "testing123"
  secret_key_base        = "todo-a"
  rollbar_env            = "todo"
  rollbar_access_token   = "todo"
  basicauth_username     = "scaleadmin"
  basicauth_password     = "!tempPassword357"
  redis_url              = module.memcached.redis_url
  elasticsearch_url      = module.elasticsearch.elasticsearch_url
  memcached_endpoint     = module.memcached.memcached_endpoint
  //sidekiq_username      = ""
  //sidekiq_password      = ""
  buyer_ui_url = "SCALE-EU2-SBX4-NLB-EXTERNAL-be555c18a567cdc7.elb.eu-west-2.amazonaws.com:8080"
  //sendgrid_username     = ""
  //sendgrid_password     = ""
  app_domain            = "SCALE-EU2-SBX4-NLB-EXTERNAL-be555c18a567cdc7.elb.eu-west-2.amazonaws.com:8081"
  aws_access_key        = ""
  aws_secret_access_key = ""
  s3_region             = "eu-west-2"
  s3_bucket_name        = module.s3.s3_static_bucket_name
  security_groups       = [aws_security_group.spree.id]
  env_file              = module.s3.env_file_spree
}

######################################
# Sidekiq Service
######################################

module "sidekiq" {
  source                 = "../../services/sidekiq"
  environment            = var.environment
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id         = module.ecs.ecs_cluster_id
  lb_public_arn          = data.aws_ssm_parameter.lb_public_arn.value
  private_app_subnet_ids = split(",", data.aws_ssm_parameter.private_app_subnet_ids.value)
  execution_role_arn     = aws_iam_role.ecs_task_execution_role.arn
  app_port               = "4567"
  cpu                    = 512
  memory                 = 2048
  aws_region             = "eu-west-2"
  db_name                = module.postgres.db_name
  db_host                = module.postgres.db_host
  db_username            = module.postgres.db_username
  db_password            = "testing123"
  secret_key_base        = "todo-a"
  rollbar_env            = "todo"
  rollbar_access_token   = "todo"
  basicauth_username     = "scaleadmin"
  basicauth_password     = "!tempPassword357"
  redis_url              = module.memcached.redis_url
  elasticsearch_url      = module.elasticsearch.elasticsearch_url
  memcached_endpoint     = module.memcached.memcached_endpoint
  //sidekiq_username      = ""
  //sidekiq_password      = ""
  buyer_ui_url = "SCALE-EU2-SBX4-NLB-EXTERNAL-be555c18a567cdc7.elb.eu-west-2.amazonaws.com:8080"
  //sendgrid_username     = ""
  //sendgrid_password     = ""
  app_domain            = "SCALE-EU2-SBX4-NLB-EXTERNAL-be555c18a567cdc7.elb.eu-west-2.amazonaws.com:8081"
  aws_access_key        = ""
  aws_secret_access_key = ""
  s3_region             = "eu-west-2"
  s3_bucket_name        = module.s3.s3_static_bucket_name
  security_groups       = [aws_security_group.spree.id]
  env_file              = module.s3.env_file_spree
}

######################################
# Client/Buyer UI Service
######################################

module "client" {
  source                = "../../services/client"
  environment           = var.environment
  vpc_id                = data.aws_ssm_parameter.vpc_id.value
  ecs_cluster_id        = module.ecs.ecs_cluster_id
  lb_public_arn         = data.aws_ssm_parameter.lb_public_arn.value
  public_web_subnet_ids = split(",", data.aws_ssm_parameter.public_web_subnet_ids.value)
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  client_app_port       = "8080" //8080
  client_app_host       = "0.0.0.0"
  client_cpu            = 256
  client_memory         = 512
  aws_region            = "eu-west-2"
  spree_api_host        = "SCALE-EU2-SBX4-NLB-EXTERNAL-be555c18a567cdc7.elb.eu-west-2.amazonaws.com:4567"
  rollbar_access_token  = "todo"
  basicauth_username    = "scaleadmin"
  basicauth_password    = "!tempPassword357"
  client_session_secret = "sessionSecret"
  security_groups       = [aws_security_group.client.id]
  env_file              = module.s3.env_file_client
}

/*
module "api-deployment" {
  source            = "../../services/api-deployment"
  environment       = var.environment
  scale_rest_api_id = module.api.scale_rest_api_id
  api_rate_limit    = var.api_rate_limit
  api_burst_limit   = var.api_burst_limit

  // Simulate depends_on:
  client_api_gateway_integration = module.client.client_api_gateway_integration
  //guided_match_api_gateway_integration  = module.guided-match.guided_match_api_gateway_integration
}
*/
