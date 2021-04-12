module "globals" {
  source      = "../../globals"
  environment = var.environment
}

#######################################################################
# NLB target group & listener for traffic on port 4567 -> 4567 (S3 Virus Scan app)
# through the internal NLB for connections from the event driven Lambda
#######################################################################
resource "aws_lb_target_group" "target_group_4567_nlb" {
  name        = "SCALE-EU2-${upper(var.environment)}-VPC-TG-S3VSCN-NLB"
  port        = 4567
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(module.globals.project_resource_tags, { AppType = "LOADBALANCER" })
}

resource "aws_lb_listener" "port_4567_internal" {
  load_balancer_arn = var.lb_private_nlb_arn
  port              = "4567"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_4567_nlb.arn
  }
}

data "template_file" "app_s3_virus_scan" {
  template = file("${path.module}/s3_virus_scan.json.tpl")

  vars = {
    app_image             = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/s3-virus-scan:${var.ecr_image_id_s3_virus_scan}"
    app_port              = var.app_port
    cpu                   = var.cpu
    memory                = var.memory
    aws_region            = var.aws_region
    name                  = "s3-virus-scan-task"
    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
  }
}

resource "aws_ecs_task_definition" "app_s3_virus_scan" {
  family                   = "s3-virus-scan-task"
  execution_role_arn       = var.execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.app_s3_virus_scan.rendered
}

resource "aws_ecs_service" "s3_virus_scan" {
  name                               = "s3-virus-scan-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.app_s3_virus_scan.arn
  desired_count                      = length(var.private_app_subnet_ids)
  launch_type                        = "EC2"
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_app_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_4567_nlb.arn
    container_name   = "s3-virus-scan-task"
    container_port   = var.app_port
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/s3_virus_scan"
  retention_in_days = var.ecs_log_retention_in_days
}


resource "aws_security_group" "s3-virus-scan-lambda" {
  vpc_id      = var.vpc_id
  name        = "s3-virus-scan-lambda-${lower(var.stage)}"
  description = "Allow inbound db traffic"
}

resource "aws_security_group_rule" "s3-virus-scan-lambda-allow-http" {
  type              = "egress"
  from_port         = 4567
  to_port           = 4567
  protocol          = "tcp"
  security_group_id = aws_security_group.s3-virus-scan-lambda.id
  cidr_blocks       = var.cidr_blocks
}

module "s3_virus_scan_lambda" {
  source          = "./lambda"
  environment     = var.environment
  host            = var.host
  subnet_ids      = var.private_app_subnet_ids
  security_groups = [aws_security_group.s3-virus-scan-lambda.id]
}

