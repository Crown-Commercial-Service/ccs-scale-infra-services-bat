[
  {
    "name": "${name}",
    "image": "${app_image}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/service/scale/spree",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "environmentFiles": [
      {
        "type": "s3",
        "value": "${env_file}"
      }
    ],
    "environment": [
      {
        "name": "DB_NAME",
        "value": "${db_name}"
      },
      {
        "name": "DB_HOST",
        "value": "${db_host}"
      },
      {
        "name": "DB_USERNAME",
        "value": "${db_username}"
      },
      {
        "name": "DB_PASSWORD",
        "value": "${db_password}"
      },
      {
        "name": "SECRET_KEY_BASE",
        "value": "${secret_key_base}"
      },
      {
        "name": "BASICAUTH_USERNAME",
        "value": "${basicauth_username}"
      },
      {
        "name": "BASICAUTH_PASSWORD",
        "value": "${basicauth_password}"
      },
      {
        "name": "BASICAUTH_ENABLED",
        "value": "${basicauth_enabled}"
      },
      {
        "name": "ROLLBAR_ACCESS_TOKEN",
        "value": "${rollbar_spree_access_token}"
      },
      {
        "name": "REDIS_URL",
        "value": "${redis_url}"
      },
      {
        "name": "MEMCACHED_ENDPOINT",
        "value": "${memcached_endpoint}:11211"
      },
      {
        "name": "PRODUCTS_IMPORT_BUCKET",
        "value": "${products_import_bucket}"
      },
      {
        "name": "ROLLBAR_ENV",
        "value": "${rollbar_env}"
      },
      {
        "name": "ELASTICSEARCH_URL",
        "value": "${elasticsearch_url}"
      },
      {
        "name": "APP_DOMAIN",
        "value": "${app_domain}"
      },
      {
        "name": "BUYER_UI_URL",
        "value": "${buyer_ui_url}"
      },
      {
        "name": "AWS_REGION",
        "value": "${aws_region}"
      },
      {
        "name": "NEW_RELIC_LICENSE_KEY",
        "value": "${new_relic_license_key}"
      },
      {
        "name": "NEW_RELIC_APP_NAME",
        "value": "${new_relic_app_name}"
      },
      {
        "name": "NEW_RELIC_AGENT_ENABLED",
        "value": "${new_relic_agent_enabled}"
      }
    ],
    "command": [
      "bundle", "exec", "rails","s","-b","0.0.0.0","-p", "${app_port}"
    ],
    "portMappings": [
      {
        "containerPort": ${app_port},
        "protocol": "tcp"
      }
    ]
  }
]
