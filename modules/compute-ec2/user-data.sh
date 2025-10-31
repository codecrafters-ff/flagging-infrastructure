#!/bin/bash
# ------------------------------------------------------------------
# Bootstrapping EC2 instance for Feature Flag API development
# Setup: Docker + user management + SSH key-based access
# ------------------------------------------------------------------

set -xe

# === system setup ===
yum update -y
amazon-linux-extras install docker -y
systemctl enable docker
systemctl start docker

# --- ec2-user can use docker (for safety/debugging) ---
usermod -aG docker ec2-user

# === create users with SSH key-based access ===
create_user() {
  local username=$1
  local pubkey=$2
  local sudo_access=$3

  echo "Creating user: $username"
  useradd -m -s /bin/bash "$username"
  usermod -aG docker "$username"

  # grant sudo
  if [ "$sudo_access" = "true" ]; then
    usermod -aG sudo "$username"
    echo "$username ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$username
  fi

  # setup SSH directory and authorized_keys
  mkdir -p /home/$username/.ssh
  echo "$pubkey" > /home/$username/.ssh/authorized_keys
  chmod 700 /home/$username/.ssh
  chmod 600 /home/$username/.ssh/authorized_keys
  chown -R $username:$username /home/$username/.ssh
}

# === team SSH public keys ===
ongeziwe_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDL0jT8kt8H2Dv7VWO28IAiu89xTZHrhEvBu8qZy2wMeoaEmyj168h7yQF+FoO/HGFxPvySnVjZ7IG9R+ZsFCPsJvd4AqAp9sZ8CBqNkPGpaxj1ytOicluQOtZF/IhW0Q6xlwn0WgEI/myFwj51rAFAfuNm+sqPm7b6W2SRGcr06p67LYsGi0BPdVcgqo0x1LscT+y6Zi7GtyZOoWKZTTsMeSrN1qxnnT21viIc6N/KZjIqomt9Qp7f17GemjC0pu2m0x8KOa/iruyHGY/aAJpEb2RSU0dP5fAe4zq/8qnwBtyrhe0L6/2Npm6ssU1Jah2qt89xVPg62NjcRSJQKyukV1WqFLXDX17ZBwXTGvKPz8PHk7Ve2yHRD15DOTuwIPMLvJ6AoFTSyhJd+NXFK9nPIYB4Dy3SrxsjVm+DHw1zXn7CXN7EoaGEEp+kUEnSxXmxmlb3/iBTE1+Rckma4niwqWWJUEIwqNRbPCph8qtI3WfuXpCLtUsYJ47135Plowbe0p7tBo+lw6v9LS79qpS5oxqbXTm9KFabOk0XssIX6WFFvI3BZx0+Ol5MIW0bN+FKcQ2ktXGK3m/ZqTR6z26zP0lGxLguqWAGgz7hr3Yi7gfyMrF4NhhztPFNDAhRzdrm8sbu/ouGxpShEdcq33fEleEQjOES1L1PRRlk2CD6vQ== hollywoodbets\ongeziwem@ZAWC-BET-3FDD8I"
# teammate1_pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD...TEAMMATE1_KEY"

# === Create users ===
create_user "ongeziwe" "$ongeziwe_pubkey" "true"
# create_user "teammate1" "$teammate1_pubkey" "false"

# === disable password login globally (key-based only) ===
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart sshd

# === Clean up and log ===
echo "User and Docker setup completed successfully." >> /var/log/user-setup.log
