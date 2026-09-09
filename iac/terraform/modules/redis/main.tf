# Valkey Serverless (Redis)
resource "aws_elasticache_serverless_cache" "this" {

  engine = "valkey"
  name   = local.redis_name

  cache_usage_limits {

    data_storage {
      maximum = 1
      unit    = "GB"
    }

    ecpu_per_second {
      maximum = 1000
    }
  }

  description          = "${local.redis_name}-${local.name}"
  major_engine_version = "9"

  security_group_ids = [
    var.redis_security_group_id
  ]

  subnet_ids = var.redis_subnet_ids

  tags = merge(

    local.common_tags,

    {

      Name = "${local.redis_name}-${local.name}"

    }
  )
}
