#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

sudo yum install -y ec2-instance-connect

# create sparks-user for ec2-instance-connect
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html
SPARKS_USER_SSH_HOME=/home/sparks-user/.ssh
EC2_USER_SSH_HOME=/home/ec2-user/.ssh
useradd sparks-user
sudo mkdir $SPARKS_USER_SSH_HOME
sudo chown sparks-user:sparks-user $SPARKS_USER_SSH_HOME
sudo chmod 700 $SPARKS_USER_SSH_HOME
sudo cp $EC2_USER_SSH_HOME/authorized_keys $SPARKS_USER_SSH_HOME
sudo chmod 600 $SPARKS_USER_SSH_HOME/authorized_keys
sudo chown sparks-user:sparks-user $SPARKS_USER_SSH_HOME/authorized_keys
