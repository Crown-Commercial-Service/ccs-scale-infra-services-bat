##########################################################
# ECS
#
# ECS shared resources
##########################################################
module "globals" {
  source      = "../globals"
  environment = var.environment
}

locals {
  cluster_name = "SCALE-EU2-${var.environment}-APP-ECS_BAT_${var.resource_name_suffix}"
}

resource "aws_ecs_cluster" "main" {
  name = local.cluster_name
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "SCALE-EU2-${var.environment}-APP-ECS_BAT_${var.resource_name_suffix}"
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.ecs-launch-configuration.name

  desired_capacity = length(var.subnet_ids)
  min_size         = length(var.subnet_ids)
  max_size         = length(var.subnet_ids)
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name_prefix                 = "SCALE-EU2-${var.environment}-ASG-LC_BAT_${var.resource_name_suffix}_"
  image_id                    = "ami-09f5dea513082ee2d"
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  user_data                   = data.template_file.user_data.rendered
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  key_name                    = "${lower(var.environment)}-spree-key"
  security_groups             = var.security_group_ids

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.tpl")

  vars = {
    cluster_name = local.cluster_name
  }
}

# Define the role.
resource "aws_iam_role" "ecs_agent" {
  name               = "SCALE_ECS_BAT_${var.resource_name_suffix}_Agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

# Allow EC2 service to assume this role.
data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Give this role the permission to do ECS Agent things.
resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = aws_iam_role.ecs_agent.name
  role = aws_iam_role.ecs_agent.name
}
