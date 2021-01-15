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
