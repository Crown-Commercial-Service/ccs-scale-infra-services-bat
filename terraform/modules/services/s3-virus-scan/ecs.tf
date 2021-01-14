module "globals" {
  source      = "../../globals"
  environment = var.environment
}

data "template_file" "app_s3_virus_scan" {
  template = file("${path.module}/s3_virus_scan.json.tpl")

  vars = {
    app_image                  = "${module.globals.env_accounts["mgmt"]}.dkr.ecr.eu-west-2.amazonaws.com/scale/s3-virus-scan:${var.ecr_image_id_spree}"
    app_port                   = var.app_port
    cpu                        = var.cpu
    memory                     = var.memory
    aws_region                 = var.aws_region
    name                       = "s3-virus-scan-task"
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
  name                               = "s3_virus_scan-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = aws_ecs_task_definition.s3_virus_scan.arn
  desired_count                      = length(var.private_app_subnet_ids)
  launch_type                        = "EC2"
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_app_subnet_ids
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/service/scale/s3_virus_scan"
  retention_in_days = 7
}
