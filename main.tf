resource "ibm_compute_vm_instance" "gitea_node" {
  hostname             = var.hostname
  domain               = var.domain
  os_reference_code    = var.os_image
  datacenter           = var.datacenter
  network_speed        = 1000
  hourly_billing       = true
  private_network_only = false
  local_disk           = true
  # user_metadata        = templatefile("${path.module}/gitea-installer.sh", { db_root_password = random_id.rootpass.hex, db_password = random_id.dbpass.hex })
  user_metadata   = file("${path.module}/gitea-installer.sh")
  flavor_key_name = var.flavor
  tags            = [var.datacenter]
  ssh_key_ids     = [data.ibm_compute_ssh_key.deploymentKey.id]
}

