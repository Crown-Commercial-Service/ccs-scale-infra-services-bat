[
  {
    "name": "${name}",
    "image": "${app_image}",
    "cpu": ${cpu},
    "memory": ${memory},
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
        "name": "SUPPLIERS_SFTP_BUCKET",
        "value": "${suppliers_sftp_bucket}"
      },
      {
        "name": "LOGIT_HOSTNAME",
        "value": "${logit_hostname}"
      },
      {
        "name": "LOGIT_REMOTE_PORT",
        "value": "${logit_remote_port}"
      },
      {
        "name": "LOGRAGE_ENABLED",
        "value": "${lograge_enabled}"
      },
      {
        "name": "SENDGRID_API_KEY",
        "value": "${sendgrid_api_key}"
      },
      {
        "name": "MAIL_FROM",
        "value": "${mail_from}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY",
        "value": "${sidekiq_concurrency}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_SEARCHKICK",
        "value": "${sidekiq_concurrency_searchkick}"
      },
      {
        "name": "ELASTICSEARCH_LIMIT",
        "value": "${elasticsearch_limit}"
      },
      {
        "name": "CNET_FTP_ENDPOINT",
        "value": "${cnet_ftp_endpoint}"
      },
      {
        "name": "CNET_FTP_PORT",
        "value": "${cnet_ftp_port}"
      },
      {
        "name": "CNET_FTP_USERNAME",
        "value": "${cnet_ftp_username}"
      },
      {
        "name": "CNET_FTP_PASSWORD",
        "value": "${cnet_ftp_password}"
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
