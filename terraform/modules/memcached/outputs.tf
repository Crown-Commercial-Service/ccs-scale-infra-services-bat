output "redis_url" {
    value = "redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}:6379"
}

output "memcached_endpoint" {
    value = aws_elasticache_cluster.memcached.cluster_address
}
