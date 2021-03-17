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
          "awslogs-group": "/ecs/service/scale/bat-buyer-ui",
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
        "name": "BROWSER_ROLLBAR_ACCESS_TOKEN",
        "valueFrom": "${browser_rollbar_access_token_ssm_arn}"
      },
      {
        "name": "SESSION_COOKIE_SECRET",
        "valueFrom": "${client_session_secret_ssm_arn}"
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
        "name": "LOGIT_NODE",
        "valueFrom": "${logit_node_ssm_arn}"
      }
    ],
    "environment": [
      {
        "name": "API_HOST",
        "value": "${api_host}"
      },
      {
        "name": "PORT",
        "value": "${app_port}"
      },
      {
        "name": "BASICAUTH_ENABLED",
        "value": "${basicauth_enabled}"
      },
      {
        "name": "SPREE_API_HOST",
        "value": "${spree_api_host}"
      },
      {
        "name": "ROLLBAR_ENV",
        "value": "${rollbar_env}"
      },
      {
        "name": "SPREE_IMAGE_HOST",
        "value": "${spree_image_host}"
      },
      {
        "name": "SPREE_API_HOST",
        "value": "${spree_api_host}"
      },
      {
        "name": "DOCUMENTS_TERMS_AND_CONDITIONS_URL",
        "value": "${documents_terms_and_conditions_url}"
      },
      {
        "name": "ENABLE_BASKET",
        "value": "${enable_basket}"
      },
      {
        "name": "ENABLE_QUOTES",
        "value": "${enable_quotes}"
      },
      {
        "name": "LOGIT_APPLICATION",
        "value": "${logit_application}"
      },
      {
        "name": "ERROR_PAGES_EXPOSE_UNKNOWN_SERVER_ERROR_ENDPOINT",
        "value": "${error_pages_unknonwn_server_endpoint}"
      }
    ],
    "command": [
      "npm", "run", "server"
    ],
    "portMappings": [
      {
        "containerPort": ${app_port},
        "protocol": "tcp"
      }
    ]
  }
]

