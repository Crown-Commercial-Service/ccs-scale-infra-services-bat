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

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = var.lb_public_alb_arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_8080.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

# TEMPORARY - REFACTOR - JUST MIMICS MANUAL CHANGES IN CONSOLE
# Data sources for the ALB custom domain name and SSL certificate
data "aws_ssm_parameter" "hosted_zone_name_alb" {
  name = "${lower(var.environment)}-hosted-zone-name-alb"
}

data "aws_acm_certificate" "alb" {
  domain   = data.aws_ssm_parameter.hosted_zone_name_alb.value
  statuses = ["ISSUED"]
}

resource "aws_lb_listener" "port_443" {
  load_balancer_arn = var.lb_public_alb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = data.aws_acm_certificate.alb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_8080.arn
  }
}


# https://github.com/hashicorp/terraform/issues/19601
data "template_file" "app_client" {
  template = file("${path.module}/client.json.tpl")

  vars = {
    app_image             = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/bat-buyer-ui-staging:${var.ecr_image_id_client}"
    app_port              = var.client_app_port
    fargate_cpu           = var.client_cpu
    fargate_memory        = var.client_memory
    aws_region            = var.aws_region
    name                  = "client-app-task"
    api_host              = var.client_app_host
    spree_api_host        = var.spree_api_host
    rollbar_access_token  = var.rollbar_access_token
    basicauth_username    = var.basicauth_username
    basicauth_password    = var.basicauth_password
    basicauth_enabled     = var.basicauth_enabled
    rollbar_env           = var.rollbar_env
    spree_image_host      = "https://${var.spree_image_host}"
    env_file              = var.env_file
    client_session_secret = var.client_session_secret
  }
}

resource "aws_ecs_task_definition" "app_client" {
  family                   = "client-app-task"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.client_cpu
  memory                   = var.client_memory
  container_definitions    = data.template_file.app_client.rendered
}


resource "aws_ecs_service" "client" {
  name            = "client-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_client.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.public_web_subnet_ids
  }

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
  retention_in_days = 7
}
