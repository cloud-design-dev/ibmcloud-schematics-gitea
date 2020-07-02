data "ibm_compute_ssh_key" "deploymentKey" {
  label = var.ssh_key
}