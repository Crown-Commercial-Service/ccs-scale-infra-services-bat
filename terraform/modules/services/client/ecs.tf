##########################################################
# Service: BaT Buyer UI (client)
#
# Deployed in public (web) subnet
##########################################################

module "globals" {
  source      = "../../globals"
  environment = var.environment
}

#######################################################################
# NLB target group & listener for traffic on port 7010 (Agreements API)
#######################################################################
resource "aws_lb_target_group" "target_group_8080" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-BaTClient"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
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
    target_group_arn = aws_lb_target_group.target_group_8080.arn
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

# https://github.com/hashicorp/terraform/issues/19601
data "template_file" "app_client" {
  template = file("${path.module}/client.json.tpl")

  vars = {
    app_image                            = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/bat-buyer-ui-staging:${var.ecr_image_id_client}"
    app_port                             = var.client_app_port
    cpu                                  = var.cpu
    memory                               = var.memory
    aws_region                           = var.aws_region
    name                                 = "client-app-task"
    api_host                             = var.client_app_host
    spree_api_host                       = var.spree_api_host
    spree_image_host                     = var.spree_image_host
    basicauth_enabled                    = var.basicauth_enabled
    rollbar_env                          = var.rollbar_env
    documents_terms_and_conditions_url   = var.documents_terms_and_conditions_url
    enable_basket                        = var.enable_basket
    enable_quotes                        = var.enable_quotes
    logit_application                    = var.logit_application
    error_pages_unknonwn_server_endpoint = var.error_pages_unknonwn_server_endpoint
    enable_ordering                      = var.enable_ordering

    # Secrets
    browser_rollbar_access_token_ssm_arn = var.browser_rollbar_access_token_ssm_arn
    client_session_secret_ssm_arn        = var.client_session_secret_ssm_arn
    rollbar_access_token_ssm_arn         = var.rollbar_access_token_ssm_arn
    basicauth_username_ssm_arn           = var.basicauth_username_ssm_arn
    basicauth_password_ssm_arn           = var.basicauth_password_ssm_arn
    logit_hostname_ssm_arn               = var.logit_hostname_ssm_arn
    logit_remote_port_ssm_arn            = var.logit_remote_port_ssm_arn
    logit_node_ssm_arn                   = var.logit_node_ssm_arn
  }
}

resource "aws_ecs_task_definition" "app_client" {
  family                   = "client-app-task"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.app_client.rendered
}


resource "aws_ecs_service" "client" {
  name                               = "client-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.app_client.arn
  desired_count                      = length(var.public_web_subnet_ids)
  launch_type                        = "EC2"
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_8080.arn
    container_name   = "client-app-task"
    container_port   = 8080
  }

  # TODO: need to opt-in to new arn and resource id formats before can enable tags - need to understand this first
  # https://aws.amazon.com/blogs/compute/migrating-your-amazon-ecs-deployment-to-the-new-arn-and-resource-id-format-2/
  #tags = merge(module.globals.project_resource_tags, {AppType = "ECS"})
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/bat-buyer-ui"
  retention_in_days = var.ecs_log_retention_in_days
}
