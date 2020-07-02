variable "iaas_classic_username" {
  description = "IBM Cloud IaaS Username."
  type        = string
  default     = ""
}

variable "iaas_classic_api_key" {
  description = "IBM Cloud IaaS User API key."
  type        = string
  default     = ""
}

variable "os_image" {
  description = "Default operating system image for compute instance."
  type        = string
  default     = "UBUNTU_18_64"
}

variable "flavor" {
  description = "Default instance size."
  type        = string
  default     = "BL2_2X4X100"
}

variable "domain" {
  description = "Domain for compute instance."
  type        = string
  default     = ""
}

variable "datacenter" {
  description = "Datacenter where instance will be deployed."
  type        = string
  default     = ""
}

variable "ssh_key" {
  description = "Classic IaaS ssh key to add to compute instance."
  type        = string
  default     = ""
}

variable "hostname" {
  description = "Hostname for instance."
  type        = string
  default     = ""
}

variable "email" {
  description = "Email used for Lets Encrypt certificate renewal notice."
  type        = string
  default     = ""
}