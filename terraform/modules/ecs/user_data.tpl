#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

sudo yum install -y ec2-instance-connect

# create sparks-user - see https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html
# explicit chown and absolute paths 'seemed' to be necessary
SPARKS_USER_NAME="sparks-user"
SPARKS_USER_SSH_HOME=/home/sparks-user/.ssh
SPARKS_USER_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCB8vQkDas0FNxNrQhbtsLhz3FezNRL7LhtepHKaPvihRyfPXL7/K96O6Us0Nfv0S7DaOJvjUZ8DBSJ2oNeqZkPt859Odty++WQsd+rWKYaVFy8lrQ19Vbwdp2e2QqpopQLQf1nPxBKN6DsDFZZyFJt9zrn7GXWSIDtnqJ79DXfPZgkxvM6AABPijmmHZvNFPMYUECjRWJ/Ho64DpVcdrmspjr6+5unhbczQ8q3oICohS0xT4uxcHmUI0PgE6+M2/ZRXxOcb/mQC0GAKo9C3c0sILzD1tuJf0C0OnW+9ZGTnCdhO6mn1Vi8LvF7ZDMH7qdqkOfAmmP/t/lGPaC5jLdF"
sudo adduser $SPARKS_USER_NAME
sudo mkdir $SPARKS_USER_SSH_HOME
sudo chmod 700 $SPARKS_USER_SSH_HOME
sudo chown $SPARKS_USER_NAME:$SPARKS_USER_NAME $SPARKS_USER_SSH_HOME
sudo echo $SPARKS_USER_PUBLIC_KEY >> $SPARKS_USER_SSH_HOME/authorized_keys
sudo chmod 600 $SPARKS_USER_SSH_HOME/authorized_keys
sudo chown $SPARKS_USER_NAME:$SPARKS_USER_NAME $SPARKS_USER_SSH_HOME/authorized_keys

# Add docker permissions
sudo usermod -aG docker $SPARKS_USER_NAME
newgrp docker
