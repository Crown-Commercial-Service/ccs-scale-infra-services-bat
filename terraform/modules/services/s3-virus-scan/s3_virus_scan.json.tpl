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
          "awslogs-group": "/ecs/service/scale/s3_virus_scan",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": [
      {
        "name": "AWS_REGION",
        "value": "${aws_region}"
      }
    ],
    "secrets": [
      {
        "name": "AWS_ACCESS_KEY_ID",
        "value": "${aws_access_key_id}"
      },
      {
        "name": "AWS_SECRET_ACCESS_KEY",
        "value": "${aws_secret_access_key}"
      }
    ],
    "command": [
      "bundle", "exec", "ruby","ccs-s3-virus-scan.rb"
    ],
    "portMappings": [
      {
        "containerPort": ${app_port},
        "protocol": "tcp"
      }
    ]
  }
]
