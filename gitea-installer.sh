#!/usr/bin/env bash 

# Generate Gitea admin password.
gitea_admin_password=$(openssl rand -hex 24)

# Save the passwords
cat > /root/.gitea_password <<EOM
gitea_admin_password="${gitea_admin_password}"
EOM

# script based on installation script found here: https://git.coolaj86.com/coolaj86/gitea-installer.sh/src/branch/master/install.bash

# Add git user
adduser git --home /var/lib/gitea --disabled-password --gecos ''

mkdir -p /var/lib/gitea/.ssh /var/lib/gitea/conf
chown git:git -R /var/lib/gitea

echo "GITEA_WORK_DIR=/var/lib/gitea" >> /etc/environment
echo "GITEA_CUSTOM=/var/lib/gitea" >> /etc/environment

# Fetch latest gitea version
VER="1.12.1"

# Download Gitea
curl -fsSL -o "/usr/bin/gitea" "https://dl.gitea.io/gitea/$VER/gitea-$VER-linux-amd64"

# Setup Gitea permissions
chmod +x /usr/bin/gitea

# allow binding on ports lower than 1024
setcap 'cap_net_bind_service=+ep' /usr/bin/gitea

# get IP
myip=$(hostname -I | awk '{print$1}')

# generate secret keys (used for session generation, and more crypto)
gitea_secret_key=$(gitea generate secret SECRET_KEY)
gitea_internal_token=$(gitea generate secret INTERNAL_TOKEN)
gitea_jwt_key=$(gitea generate secret LFS_JWT_SECRET)
gitea_lfs_secret=$(gitea generate secret LFS_JWT_SECRET)

# generate simple conf
cat >/var/lib/gitea/conf/app.ini <<EOL
APP_NAME = Gitea: Git with a cup of tea
RUN_USER = git

; CONFIGURATION DOCUMENTATION: https://docs.gitea.io/en-us/config-cheat-sheet/

[server]
PROTOCOL = http
DOMAIN = ${myip}
; CHANGE DOMAIN TO YOUR ACTUAL DOMAIN
HTTP_PORT = 80
LFS_JWT_SECRET = ${gitea_lfs_secret}

[database]
DB_TYPE = sqlite3
PATH = /var/lib/gitea/gitea.db

[security]
INSTALL_LOCK = true
SECRET_KEY = ${gitea_secret_key}
INTERNAL_TOKEN = ${gitea_internal_token}

[mailer]
ENABLED = true
MAILER_TYPE = sendmail
FROM = Gitea <gitea@${myip}.xip.io>
; CHANGE THE DOMAIN ABOVE IN THE MAIL ADDRESS TO YOUR ACTUAL DOMAIN

[oauth2]
JWT_SECRET = ${gitea_jwt_key}

[picture]
DISABLE_GRAVATAR        = false
ENABLE_FEDERATED_AVATAR = false

[repository]
ROOT = /var/lib/gitea/gitea-repositories

[service]
DISABLE_REGISTRATION = true
EOL

cd /var/lib/gitea

su git -c "GITEA_WORK_DIR=/var/lib/gitea GITEA_CUSTOM=/var/lib/gitea /usr/bin/gitea migrate"
su git -c "GITEA_WORK_DIR=/var/lib/gitea GITEA_CUSTOM=/var/lib/gitea /usr/bin/gitea admin create-user --admin --name gitea_admin --password ${gitea_admin_password} --email gitea_admin@example.com"

cat >/etc/systemd/system/gitea.service <<EOL
[Unit]
Description=Gitea - Git with a cup of tea. A painless self-hosted Git service.
Documentation=https://docs.gitea.io/
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
# Restart on crash (bad signal), but not on 'clean' failure (error exit code)
# Allow up to 3 restarts within 10 seconds
# (it's unlikely that a user or properly-running script will do this)
Restart=on-abnormal
StartLimitInterval=10
StartLimitBurst=3

# User and group the process will run as
# (git is the de facto standard on most systems)
User=git
Group=git
Environment="GITEA_WORK_DIR=/var/lib/gitea" "GITEA_CUSTOM=/var/lib/gitea"
WorkingDirectory=/var/lib/gitea
ExecStart=/usr/bin/gitea web
ExecReload=/bin/kill -USR1 $MAINPID

LimitNOFILE=1048576
LimitNPROC=64

PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectSystem=full
ReadWriteDirectories=/var/lib/gitea

CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target

EOL

## Add MOTD for initial login
cat >/etc/update-motd.d/99-gitea-info <<EOL
#!/bin/sh

publicIp=$(curl -s https://api.service.softlayer.com/rest/v3.1/SoftLayer_Resource_Metadata/getPrimaryIpAddress | cut -d '"' -f2)
cat <<EOF
********************************************************************************

Welcome to your Gitea instance. 
To keep this Droplet secure, the UFW firewall is enabled.
All ports are BLOCKED except 22 (SSH), 80 (HTTP), and 443 (HTTPS).

In a web browser, you can view:
 * Your Gitea website: http://$publicIp
 * You can log in as gitea_admin 

On the server:
 * The gitea_admin user password is saved in /root/.gitea_password
   * This is used for the first default user
   * Please create new user with admin permissions and delete default
 * Gitea configuration is located at /var/lib/gitea/conf/app.ini

For help and more information, visit https://docs.gitea.io/en-us/faq/

********************************************************************************
To delete this message of the day: rm -rf $(readlink -f ${0})
EOF

EOL

chmod +x /etc/update-motd.d/99-gitea-info

# Protect the compute instance
ufw limit ssh
ufw allow https
ufw allow http
ufw --force enable


systemctl enable gitea
systemctl start gitea