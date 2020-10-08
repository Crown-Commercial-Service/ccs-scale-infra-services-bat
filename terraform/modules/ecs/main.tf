resource "aws_ecs_cluster" "main" {
  name = "cb-cluster"
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  name                 = "ecs-autoscaling-group"
  vpc_zone_identifier  = var.public_web_subnet_ids
  launch_configuration = aws_launch_configuration.ecs-launch-configuration.name

  desired_capacity = 3
  min_size         = 3
  max_size         = 3

  tags = {
    Project     = module.globals.project_name
    Environment = upper(var.environment)
    Cost_Code   = module.globals.project_cost_code
    AppType     = "AUTOSCALINGGROUP"
  }
}

resource "aws_launch_configuration" "ecs-launch-configuration" {
  name_prefix                 = "megapool-"
  image_id                    = "ami-09f5dea513082ee2d"
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  user_data                   = data.template_file.user_data.rendered
  instance_type               = "t2.large"
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
    cluster_name = "cb-cluster"
  }
}

# Define the role.
resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
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
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}
