##############################################
# COMPUTE (EC2) MODULE USER DATA
# modules/compute-ec2/user-data.sh
##############################################
#!/bin/bash
# Bootstrapping EC2 instance for Feature Flag API
# Installs Docker and prepares environment

set -xe

# Update and install Docker
yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# Optional: Add ec2-user to Docker group
usermod -aG docker ec2-user

# # Log to CloudWatch
# echo "EC2 instance bootstrapped successfully" >> /var/log/user-data.log
