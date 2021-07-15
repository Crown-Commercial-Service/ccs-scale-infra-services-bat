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
    "secrets": [
      {
        "name": "BASICAUTH_USERNAME",
        "valueFrom": "${basicauth_username_ssm_arn}"
      },
      {
        "name": "BASICAUTH_PASSWORD",
        "valueFrom": "${basicauth_password_ssm_arn}"
      },
      {
        "name": "ROLLBAR_ACCESS_TOKEN",
        "valueFrom": "${rollbar_access_token_ssm_arn}"
      },
      {
        "name": "DB_USERNAME",
        "valueFrom": "${db_username_ssm_arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${db_password_ssm_arn}"
      },
      {
        "name": "SENDGRID_API_KEY",
        "valueFrom": "${sendgrid_api_key_ssm_arn}"
      },
      {
        "name": "CNET_FTP_USERNAME",
        "valueFrom": "${cnet_ftp_username_ssm_arn}"
      },
      {
        "name": "CNET_FTP_PASSWORD",
        "valueFrom": "${cnet_ftp_password_ssm_arn}"
      },
      {
        "name": "SECRET_KEY_BASE",
        "valueFrom": "${secret_key_base_ssm_arn}"
      },
      {
        "name": "LOGIT_HOSTNAME",
        "valueFrom": "${logit_hostname_ssm_arn}"
      },
      {
        "name": "LOGIT_REMOTE_PORT",
        "valueFrom": "${logit_remote_port_ssm_arn}"
      },
      {
        "name": "NEW_RELIC_LICENSE_KEY",
        "valueFrom": "${new_relic_license_key_ssm_arn}"
      },
      {
        "name": "SIDEKIQ_USERNAME",
        "valueFrom": "${sidekiq_username_ssm_arn}"
      },
      {
        "name": "SIDEKIQ_PASSWORD",
        "valueFrom": "${sidekiq_password_ssm_arn}"
      },
      {
        "name": "SENDGRID_USERNAME",
        "valueFrom": "${sendgrid_username_ssm_arn}"
      },
      {
        "name": "SENDGRID_PASSWORD",
        "valueFrom": "${sendgrid_password_ssm_arn}"
      },
      {
        "name": "AWS_ACCESS_KEY_ID",
        "valueFrom": "${aws_access_key_id_ssm_arn}"
      },
      {
        "name": "AWS_SECRET_ACCESS_KEY",
        "valueFrom": "${aws_secret_access_key_ssm_arn}"
      },
      {
        "name": "ORDNANCE_SURVEY_API_TOKEN",
        "valueFrom": "${ordnance_survey_api_token_ssm_arn}"
      },
      {
        "name": "DB_URL",
        "valueFrom": "${db_url_ssm_arn}"
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
        "name": "BASICAUTH_ENABLED",
        "value": "${basicauth_enabled}"
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
        "name": "LOGRAGE_ENABLED",
        "value": "${lograge_enabled}"
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
        "name": "S3_REGION",
        "value": "${aws_region}"
      },
      {
        "name": "S3_BUCKET_NAME",
        "value": "${s3_static_bucket_name}"
      },
      {
        "name": "NEW_RELIC_APP_NAME",
        "value": "${new_relic_app_name}"
      },
      {
        "name": "NEW_RELIC_AGENT_ENABLED",
        "value": "${new_relic_agent_enabled}"
      },
      {
        "name": "DEFAULT_COUNTRY_ID",
        "value": "${default_country_id}"
	    },
      {
        "name": "BUYER_ORGANIZATIONS_IMPORT_BUCKET",
        "value": "${buyer_organizations_import_bucket}"
      },
      { "name": "CNET_PRODUCTS_IMPORT_BUCKET",
        "value": "${cnet_products_import_bucket}"
      },
      {
        "name": "CNET_PRODUCTS_IMPORT_UPDATES_DIR",
        "value": "${cnet_products_import_updates_dir}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CATALOG_REINDEX",
        "value": "${sidekiq_concurrency_catalog_reindex}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_FEED",
        "value": "${sidekiq_concurrency_cnet_import_feed}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_CATEGORIES",
        "value": "${sidekiq_concurrency_cnet_import_categories}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_DOCUMENTS",
        "value": "${sidekiq_concurrency_cnet_import_documents}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_IMAGES",
        "value": "${sidekiq_concurrency_cnet_import_images}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_PROPERTIES",
        "value": "${sidekiq_concurrency_cnet_import_properties}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_XMLS",
        "value": "${sidekiq_concurrency_cnet_import_xmls}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_MISSING_PROPERTIES",
        "value": "${sidekiq_concurrency_cnet_import_missing_properties}"
      },
      {
        "name": "SIDEKIQ_CONCURRENCY_CNET_IMPORT_MISSING_XMLS",
        "value": "${sidekiq_concurrency_cnet_import_missing_xmls}"
      },
      {
        "name": "RACK_TIMEOUT_SERVICE_TIMEOUT",
        "value": "${rack_timeout_service_timeout}"
      },
      {
        "name": "ENABLE_ADMIN_PANEL_ORDERS",
        "value": "${enable_admin_panel_orders}"
      },
      {
        "name": "LOG_LEVEL",
        "value": "${log_level}"
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
