#!/usr/bin/env bash

## Update machine
DEBIAN_FRONTEND=noninteractive apt -qqy update
DEBIAN_FRONTEND=noninteractive apt-get -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' dist-upgrade

## Install Docker 
DEBIAN_FRONTEND=noninteractive apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install apt-transport-https ca-certificates curl gnupg-agent software-properties-common openssl

## Register Docker package registry
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
DEBIAN_FRONTEND=noninteractive add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

## Refresh package udpates and install Docker
DEBIAN_FRONTEND=noninteractive apt -qqy update
DEBIAN_FRONTEND=noninteractive apt -qqy -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install docker-ce docker-ce-cli containerd.io

## Create data volumes for Gitea and Mysql
docker volume create mysql
docker volume create gitea 

## Create containers 
docker create --name=db -e MYSQL_ROOT_PASSWORD=${db_root_password} -e MYSQL_USER=gitea -e MYSQL_PASSWORD=${db_password} -e MYSQL_DATABASE=gitea --expose 3306 -v mysql:/var/lib/mysql --network=gitea --restart=unless-stopped mysql:5.7
docker create --name=gitea -e USER_UID=1000 -e USER_GID=1000 -e DB_TYPE=mysql -e DB_HOST=db:3306 -e DB_NAME=gitea -e DB_USER=gitea -e DB_PASSWD=${db_password} -v gitea:/data -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --restart=unless-stopped --network=gitea --publish --expose 222 --expose 3000 gitea/gitea:latest

## Update firewall rules
ufw allow ssh
ufw allow 3000
ufw allow 222
ufw --force disable

## Start containers 
docker start db
docker start gitea