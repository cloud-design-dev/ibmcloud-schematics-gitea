output "root_db_password" {
  value = random_id.rootpass.hex
}

output "db_password" {
  value = random_id.dbpass.hex
}

output "instance_ip" {
  value = ibm_compute_vm_instance.gitea_node.ipv4_address
}