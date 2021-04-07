#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

sudo yum install -y ec2-instance-connect

# create dev-user - see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html
# explicit chown and absolute paths seemed to be necessary
DEV_USER_NAME="dev-user"
DEV_USER_SSH_HOME=/home/$DEV_USER_NAME/.ssh
DEV_USER_PUBLIC_KEY="${dev_user_public_key}"
sudo adduser $DEV_USER_NAME
sudo mkdir $DEV_USER_SSH_HOME
sudo chmod 700 $DEV_USER_SSH_HOME
sudo chown $DEV_USER_NAME:$DEV_USER_NAME $DEV_USER_SSH_HOME
sudo echo $DEV_USER_PUBLIC_KEY >> $DEV_USER_SSH_HOME/authorized_keys
sudo chmod 600 $DEV_USER_SSH_HOME/authorized_keys
sudo chown $DEV_USER_NAME:$DEV_USER_NAME $DEV_USER_SSH_HOME/authorized_keys

# Add docker permissions
sudo usermod -aG docker $DEV_USER_NAME
newgrp docker
