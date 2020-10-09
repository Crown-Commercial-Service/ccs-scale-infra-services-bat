
module "globals" {
  source = "../../globals"
}

data "template_file" "app_sidekiq" {
  template = file("${path.module}/sidekiq.json.tpl")

  vars = {
    app_image                  = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:${var.ecr_image_id_spree}"
    app_port                   = var.app_port
    fargate_cpu                = var.cpu
    fargate_memory             = var.memory
    aws_region                 = var.aws_region
    name                       = "sidekiq-task"
    db_name                    = var.db_name
    db_host                    = var.db_host
    db_username                = var.db_username
    db_password                = var.db_password
    secret_key_base            = var.secret_key_base
    basicauth_username         = var.basicauth_username
    basicauth_password         = var.basicauth_password
    basicauth_enabled          = var.basicauth_enabled
    rollbar_spree_access_token = var.rollbar_access_token
    products_import_bucket     = var.products_import_bucket
    rollbar_env                = var.rollbar_env
    env_file                   = var.env_file
    redis_url                  = var.redis_url
    elasticsearch_url          = var.elasticsearch_url
    buyer_ui_url               = var.buyer_ui_url
    app_domain                 = var.app_domain
  }
}

resource "aws_ecs_task_definition" "app_sidekiq" {
  family                   = "sidekiq-task"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.app_sidekiq.rendered
}


resource "aws_ecs_service" "sidekiq" {
  name            = "sidekiq-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_sidekiq.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_app_subnet_ids
  }

  # TODO: need to opt-in to new arn and resource id formats before can enable tags - need to understand this first
  # https://aws.amazon.com/blogs/compute/migrating-your-amazon-ecs-deployment-to-the-new-arn-and-resource-id-format-2/
  #tags = {
  #  Project     = module.globals.project_name
  #  Environment = upper(var.environment)
  #  Cost_Code   = module.globals.project_cost_code
  #  AppType     = "ECS"
  #}
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/spree-sidekiq"
  retention_in_days = 7
}
