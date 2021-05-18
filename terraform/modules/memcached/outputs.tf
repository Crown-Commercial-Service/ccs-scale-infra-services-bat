output "redis_url" {
  value = "rediss://${aws_elasticache_replication_group.redis.primary_endpoint_address}"
}

output "memcached_endpoint" {
  value = aws_elasticache_cluster.memcached.cluster_address
}
