
module "globals" {
  source      = "../../globals"
  environment = var.environment
}

#######################################################################
# NLB target group & listener for traffic on port 4567
#######################################################################
resource "aws_lb_target_group" "target_group_4567" {
  name = "SCALE-EU2-${upper(var.environment)}-VPC-BaTSpree"
  port = 4567
  #protocol    = "TCP"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  # Required for ALB operating over HTTP
  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
    path                = "/healthcheck"
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "LOADBALANCER" })
}

data "aws_acm_certificate" "alb" {
  domain   = var.hosted_zone_name
  statuses = ["ISSUED"]
}

data "aws_ssm_parameter" "external_alb_port_443_listener_arn" {
  name = "${lower(var.environment)}-ext-alb-port-443-listener-arn"
}

resource "aws_lb_listener_certificate" "bat_client" {
  listener_arn    = data.aws_ssm_parameter.external_alb_port_443_listener_arn.value
  certificate_arn = data.aws_acm_certificate.alb.arn
}

resource "aws_lb_listener_rule" "authenticate_cloudfront" {
  listener_arn = data.aws_ssm_parameter.external_alb_port_443_listener_arn.value
  # priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567.arn
  }

  condition {
    http_header {
      http_header_name = "CloudFrontID"
      values           = [var.cloudfront_id]
    }
  }

  condition {
    host_header {
      values = [var.hosted_zone_name]
    }
  }
}

#######################################################################
# NLB target group & listener for traffic on port 80 -> 4567 (Spree app)
# through the internal NLB for connections from the client app
#######################################################################
resource "aws_lb_target_group" "target_group_4567_nlb" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-SPREE-NLB"
  port        = 4567
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(module.globals.project_resource_tags, { AppType = "LOADBALANCER" })
}

resource "aws_lb_listener" "port_80_internal" {
  load_balancer_arn = var.lb_private_nlb_arn
  port              = "80"
  protocol          = "TCP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567_nlb.arn
  }
}

data "template_file" "app_client" {
  template = file("${path.module}/spree.json.tpl")

  vars = {
    app_image                      = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:${var.ecr_image_id_spree}"
    app_port                       = var.app_port
    cpu                            = var.cpu
    memory                         = var.memory
    aws_region                     = var.aws_region
    name                           = "spree-app-task"
    db_name                        = var.db_name
    db_host                        = var.db_host
    basicauth_enabled              = var.basicauth_enabled
    products_import_bucket         = var.products_import_bucket
    rollbar_env                    = var.rollbar_env
    env_file                       = var.env_file
    redis_url                      = var.redis_url
    memcached_endpoint             = var.memcached_endpoint
    elasticsearch_url              = var.elasticsearch_url
    buyer_ui_url                   = var.buyer_ui_url
    app_domain                     = var.app_domain
    suppliers_sftp_bucket          = var.suppliers_sftp_bucket
    lograge_enabled                = var.lograge_enabled
    mail_from                      = var.mail_from
    sidekiq_concurrency            = var.sidekiq_concurrency
    sidekiq_concurrency_searchkick = var.sidekiq_concurrency_searchkick
    elasticsearch_limit            = var.elasticsearch_limit
    cnet_ftp_endpoint              = var.cnet_ftp_endpoint
    cnet_ftp_port                  = var.cnet_ftp_port
    default_country_id             = var.default_country_id
    new_relic_app_name             = var.new_relic_app_name
    new_relic_agent_enabled        = var.new_relic_agent_enabled
    s3_static_bucket_name          = var.s3_static_bucket_name

    # Secrets
    db_username_ssm_arn           = var.db_username_ssm_arn
    db_password_ssm_arn           = var.db_password_ssm_arn
    secret_key_base_ssm_arn       = var.secret_key_base_ssm_arn
    basicauth_username_ssm_arn    = var.basicauth_username_ssm_arn
    basicauth_password_ssm_arn    = var.basicauth_password_ssm_arn
    rollbar_access_token_ssm_arn  = var.rollbar_access_token_ssm_arn
    cnet_ftp_username_ssm_arn     = var.cnet_ftp_username_ssm_arn
    cnet_ftp_password_ssm_arn     = var.cnet_ftp_password_ssm_arn
    sidekiq_username_ssm_arn      = var.sidekiq_username_ssm_arn
    sidekiq_password_ssm_arn      = var.sidekiq_password_ssm_arn
    sendgrid_username_ssm_arn     = var.sendgrid_username_ssm_arn
    sendgrid_password_ssm_arn     = var.sendgrid_password_ssm_arn
    sendgrid_api_key_ssm_arn      = var.sendgrid_api_key_ssm_arn
    aws_access_key_id_ssm_arn     = var.aws_access_key_id_ssm_arn
    aws_secret_access_key_ssm_arn = var.aws_secret_access_key_ssm_arn
    new_relic_license_key_ssm_arn = var.new_relic_license_key_ssm_arn
    logit_hostname_ssm_arn        = var.logit_hostname_ssm_arn
    logit_remote_port_ssm_arn     = var.logit_remote_port_ssm_arn
  }
}

resource "aws_ecs_task_definition" "app_spree" {
  family                   = "spree-app-task"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.app_client.rendered
}


resource "aws_ecs_service" "spree" {
  name                               = "spree-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.app_spree.arn
  desired_count                      = length(var.private_app_subnet_ids)
  launch_type                        = "EC2"
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_app_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_4567.arn
    container_name   = "spree-app-task"
    container_port   = var.app_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_4567_nlb.arn
    container_name   = "spree-app-task"
    container_port   = var.app_port
  }

  # TODO: need to opt-in to new arn and resource id formats before can enable tags - need to understand this first
  # https://aws.amazon.com/blogs/compute/migrating-your-amazon-ecs-deployment-to-the-new-arn-and-resource-id-format-2/
  #tags = merge(module.globals.project_resource_tags, {AppType = "ECS"})
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/spree"
  retention_in_days = 7
}
