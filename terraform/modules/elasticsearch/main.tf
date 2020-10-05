##########################################################
# Elasticsearch
##########################################################
resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "main" {
  domain_name           = "spree-elasticsearch"
  elasticsearch_version = "7.4"

  cluster_config {
    instance_type = "t2.medium.elasticsearch"
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }

  vpc_options {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = var.security_group_ids
  }

  depends_on = [
    aws_iam_service_linked_role.es,
  ]
}
