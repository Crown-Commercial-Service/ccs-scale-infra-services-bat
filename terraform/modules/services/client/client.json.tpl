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
    "environmentFiles": [
      {
        "type": "s3",
        "value": "${env_file}"
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
        "name": "ROLLBAR_ACCESS_TOKEN",
        "value": "${rollbar_access_token}"
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
        "name": "SPREE_API_HOST",
        "value": "${spree_api_host}"
      },
      {
        "name": "SESSION_COOKIE_SECRET",
        "value": "${client_session_secret}"
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
        "name": "LOGIT_HOSTNAME",
        "value": "${logit_hostname}"
      },
      {
        "name": "LOGIT_REMOTE_PORT",
        "value": "${logit_remote_port}"
      },
      {
        "name": "DOCUMENTS_TERMS_AND_CONDITIONS_URL",
        "value": "${documents_terms_and_conditions_url}"
      },
      {
        "name": "LOGIT_NODE",
        "value": "${logit_node}"
      },
      {
        "name": "BROWSER_ROLLBAR_ACCESS_TOKEN",
        "value": "${browser_rollbar_access_token}"
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

