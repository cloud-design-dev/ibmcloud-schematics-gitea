output "instance_ip" {
  value = ibm_compute_vm_instance.gitea_node.ipv4_address
}