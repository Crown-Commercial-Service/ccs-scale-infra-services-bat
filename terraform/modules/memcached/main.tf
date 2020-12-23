##########################################################
# Caches
#
# Memcached & Redis
##########################################################
module "globals" {
  source      = "../globals"
  environment = var.environment
}

resource "aws_elasticache_subnet_group" "ec" {
  name       = "tf-test-cache-subnet"
  subnet_ids = var.private_app_subnet_ids
}

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "scale-eu2-ec-spree-memcached"
  engine               = "memcached"
  engine_version       = "1.5.16"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.5"
  security_group_ids   = var.security_group_memcached_ids
  subnet_group_name    = aws_elasticache_subnet_group.ec.name

  tags = merge(module.globals.project_resource_tags, { AppType = "MEMCACHED" })
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "scale-eu2-ec-spree-redis"
  engine               = "redis"
  node_type            = "cache.t2.medium"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  security_group_ids   = var.security_group_redis_ids
  subnet_group_name    = aws_elasticache_subnet_group.ec.name

  tags = merge(module.globals.project_resource_tags, { AppType = "REDIS" })
}
