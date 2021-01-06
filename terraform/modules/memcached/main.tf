##########################################################
# Caches
#
# Memcached & Redis
##########################################################
module "globals" {
  source      = "../globals"
  environment = var.environment
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_elasticache_subnet_group" "ec" {
  name       = "tf-test-cache-subnet"
  subnet_ids = var.private_app_subnet_ids
}

resource "aws_elasticache_cluster" "memcached" {
  cluster_id                   = "scale-eu2-ec-spree-memcached"
  engine                       = "memcached"
  engine_version               = "1.6.6"
  node_type                    = var.memcached_node_type
  num_cache_nodes              = length(var.private_app_subnet_ids)
  parameter_group_name         = "default.memcached1.5"
  security_group_ids           = var.security_group_memcached_ids
  subnet_group_name            = aws_elasticache_subnet_group.ec.name
  az_mode                      = "cross-az"
  preferred_availability_zones = data.aws_availability_zones.available.names

  tags = merge(module.globals.project_resource_tags, { AppType = "MEMCACHED" })
}

resource "aws_elasticache_replication_group" "redis" {
  automatic_failover_enabled    = true
  replication_group_id          = "scale-eu2-ec-spree-redis"
  replication_group_description = "Managed by Terraform"
  node_type                     = var.redis_node_type
  port                          = 6379
  engine_version                = "6.x"
  security_group_ids            = var.security_group_redis_ids
  subnet_group_name             = aws_elasticache_subnet_group.ec.name

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = length(var.private_app_subnet_ids)
  }

  tags = merge(module.globals.project_resource_tags, { AppType = "REDIS" })
}
