
module "globals" {
  source      = "../../globals"
  environment = var.environment
}

data "template_file" "app_sidekiq" {
  template = file("${path.module}/sidekiq.json.tpl")

  vars = {
    app_image                                          = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:${var.ecr_image_id_spree}"
    app_port                                           = var.app_port
    cpu                                                = var.cpu
    memory                                             = var.memory
    aws_region                                         = var.aws_region
    name                                               = "sidekiq-task"
    db_name                                            = var.db_name
    db_host                                            = var.db_host
    basicauth_enabled                                  = var.basicauth_enabled
    products_import_bucket                             = var.products_import_bucket
    rollbar_env                                        = var.rollbar_env
    redis_url                                          = var.redis_url
    memcached_endpoint                                 = var.memcached_endpoint
    elasticsearch_url                                  = var.elasticsearch_url
    buyer_ui_url                                       = var.buyer_ui_url
    app_domain                                         = var.app_domain
    suppliers_sftp_bucket                              = var.suppliers_sftp_bucket
    lograge_enabled                                    = var.lograge_enabled
    mail_from                                          = var.mail_from
    sidekiq_concurrency                                = var.sidekiq_concurrency
    sidekiq_concurrency_searchkick                     = var.sidekiq_concurrency_searchkick
    elasticsearch_limit                                = var.elasticsearch_limit
    cnet_ftp_endpoint                                  = var.cnet_ftp_endpoint
    cnet_ftp_port                                      = var.cnet_ftp_port
    default_country_id                                 = var.default_country_id
    new_relic_app_name                                 = var.new_relic_app_name
    new_relic_agent_enabled                            = var.new_relic_agent_enabled
    s3_static_bucket_name                              = var.s3_static_bucket_name
    buyer_organizations_import_bucket                  = var.buyer_organizations_import_bucket
    cnet_products_import_bucket                        = var.cnet_products_import_bucket
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
    # Secrets
    db_username_ssm_arn               = var.db_username_ssm_arn
    db_password_ssm_arn               = var.db_password_ssm_arn
    secret_key_base_ssm_arn           = var.secret_key_base_ssm_arn
    basicauth_username_ssm_arn        = var.basicauth_username_ssm_arn
    basicauth_password_ssm_arn        = var.basicauth_password_ssm_arn
    rollbar_access_token_ssm_arn      = var.rollbar_access_token_ssm_arn
    cnet_ftp_username_ssm_arn         = var.cnet_ftp_username_ssm_arn
    cnet_ftp_password_ssm_arn         = var.cnet_ftp_password_ssm_arn
    sidekiq_username_ssm_arn          = var.sidekiq_username_ssm_arn
    sidekiq_password_ssm_arn          = var.sidekiq_password_ssm_arn
    sendgrid_username_ssm_arn         = var.sendgrid_username_ssm_arn
    sendgrid_password_ssm_arn         = var.sendgrid_password_ssm_arn
    sendgrid_api_key_ssm_arn          = var.sendgrid_api_key_ssm_arn
    aws_access_key_id_ssm_arn         = var.aws_access_key_id_ssm_arn
    aws_secret_access_key_ssm_arn     = var.aws_secret_access_key_ssm_arn
    new_relic_license_key_ssm_arn     = var.new_relic_license_key_ssm_arn
    logit_hostname_ssm_arn            = var.logit_hostname_ssm_arn
    logit_remote_port_ssm_arn         = var.logit_remote_port_ssm_arn
    ordnance_survey_api_token_ssm_arn = var.ordnance_survey_api_token_ssm_arn
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
  name                               = "sidekiq-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.app_sidekiq.arn
  desired_count                      = length(var.private_app_subnet_ids)
  launch_type                        = "EC2"
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_app_subnet_ids
  }

  # TODO: need to opt-in to new arn and resource id formats before can enable tags - need to understand this first
  # https://aws.amazon.com/blogs/compute/migrating-your-amazon-ecs-deployment-to-the-new-arn-and-resource-id-format-2/
  #tags = merge(module.globals.project_resource_tags, {AppType = "ECS"})
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/spree-sidekiq"
  retention_in_days = var.ecs_log_retention_in_days
}
