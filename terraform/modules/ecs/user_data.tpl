#!/bin/bash
echo ECS_CLUSTER=cb-cluster >> /etc/ecs/ecs.config

sudo yum install -y ec2-instance-connect
