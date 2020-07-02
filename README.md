# Gitea Server on IBM Cloud 
Gitea version control server deployed using IBM Cloud Schematics. 

## Repository Variables
 - iaas_classic_username: Classic Infrastructure User
 - iaas_classic_api_key: Classic Infrastructure API Key
 - os_image: OS Image for instance. Currently tested with Ubuntu 18
 - flavor: Compute instance profile
 - domain: Domain name for instance
 - datacenter: IBM Cloud Datacenter where instance will be deployed
 - ssh_key: Classic Infrastructure SSH Key to add to instance
 - hostname: Hostname for instance

 ## After Deployment
 Upon initial login you should see a MOTD with instructions for accessing the web interface for Gitea. Next steps:
  - Replace the instance IP with your FQDN in the Gitea ini file at `/var/lib/gitea/conf/app.ini` 
  - Log in to the web interface and add a new user
  - Disable gitea_admin user 
  - Update main server settings in `/var/lib/gitea/conf/app.ini` if you wish to send invitation emails for new users
