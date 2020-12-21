output "redis_url" {
    value = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}"
}

output "redis_cache_url" {
    value = "redis://${aws_elasticache_cluster.redis_cache.cache_nodes.0.address}"
}

output "memcached_endpoint" {
    value = aws_elasticache_cluster.memcached.cluster_address
}
