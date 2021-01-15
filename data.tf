
data "ibm_resource_group" "cde" {
  name = var.resource_group
}

data "ibm_is_zones" "regional_zones" {
  region = var.region
}

data "ibm_is_ssh_key" "regional_ssh_key" {
  name = var.ssh_key
}

data "ibm_is_image" "default" {
  name = var.os_image
}

data "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

data ibm_is_subnet subnet {
  name = var.subnet
}

data ibm_is_security_group dmz {
  name = var.security_group
}

data "digitalocean_domain" "drone" {
  name = var.domain
}