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
        "name": "PAPERTRAIL_HOSTNAME",
        "value": "${papertrail_hostname}"
      },
      {
        "name": "PAPERTRAIL_REMOTE_PORT",
        "value": "${papertrail_remote_port}"
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

