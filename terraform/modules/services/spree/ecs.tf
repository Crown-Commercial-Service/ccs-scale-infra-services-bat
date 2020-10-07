
module "globals" {
  source = "../../globals"
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

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "LOADBALANCER"
  }
}

resource "aws_lb_listener" "port_80" {
  load_balancer_arn = var.lb_public_alb_arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567.arn
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
    target_group_arn = aws_lb_target_group.target_group_4567.arn
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

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "LOADBALANCER"
  }
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
    //app_image             = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:hello-world-test-4567"
    app_image                  = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/spree-service-staging:latest"
    app_port                   = var.app_port
    fargate_cpu                = var.cpu
    fargate_memory             = var.memory
    aws_region                 = var.aws_region
    name                       = "spree-app-task"
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
    memcached_endpoint         = var.memcached_endpoint
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
  name            = "spree-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app_spree.arn
  launch_type     = "EC2"

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
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/spree"
  retention_in_days = 7
}
