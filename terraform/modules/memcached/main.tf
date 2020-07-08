
##########################################################
# Caches
#
# Memcached & Redis
##########################################################
resource "aws_elasticache_subnet_group" "ec" {
  name       = "tf-test-cache-subnet"
  subnet_ids = var.private_app_subnet_ids
}

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "memcached-spree"
  engine               = "memcached"
  node_type            = "cache.t3.medium"
  num_cache_nodes      = 2
  parameter_group_name = "default.memcached1.5"
  security_group_ids   = var.security_group_memcached_ids
  subnet_group_name    = aws_elasticache_subnet_group.ec.name
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-spree"
  engine               = "redis"
  node_type            = "cache.t2.medium"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6"
  security_group_ids   = var.security_group_redis_ids
  subnet_group_name    = aws_elasticache_subnet_group.ec.name
}