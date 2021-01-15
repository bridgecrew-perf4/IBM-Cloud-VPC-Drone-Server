locals {
  name = formatdate("DDhhmm", timestamp())
}

resource "random_id" "name" {
  byte_length = 4
}

resource tls_private_key ssh {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource ibm_is_ssh_key generated_key {
  name           = "${var.project}-${var.region}-sshkey"
  public_key     = tls_private_key.ssh.public_key_openssh
  resource_group = data.ibm_resource_group.cde.id
  tags           = concat(var.tags, ["region:${var.region}", "project:${var.project}", "version:${local.name}", "tf_workspace:${terraform.workspace}", "type:sshkey"])
}

resource ibm_is_security_group drone {
  name           = "drone-server-web"
  vpc            = data.ibm_is_vpc.vpc.id
  resource_group = data.ibm_resource_group.cde.id
}

resource "ibm_is_security_group_rule" "https_in" {
  group     = ibm_is_security_group.drone.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource ibm_is_security_group_rule http_in {
  group     = ibm_is_security_group.drone.id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource ibm_is_security_group_rule all_out {
  group     = ibm_is_security_group.drone.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource ibm_is_instance drone {
  name    = "drone-server-${data.ibm_is_zones.regional_zones.zones[0]}"
  image   = data.ibm_is_image.default.id
  profile = var.default_instance_profile

  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = [data.ibm_is_security_group.dmz.id, ibm_is_security_group.drone.id]
  }

  resource_group = data.ibm_resource_group.cde.id
  tags           = concat(var.tags, ["region:${var.region}", "project:${var.project}", "version:${local.name}", "tf_workspace:${terraform.workspace}", "type:instance"])

  vpc       = data.ibm_is_vpc.vpc.id
  zone      = data.ibm_is_zones.regional_zones.zones[0]
  keys      = [data.ibm_is_ssh_key.regional_ssh_key.id, ibm_is_ssh_key.generated_key.id]
  user_data = templatefile("${path.module}/install.yml", { temp_key = tls_private_key.ssh.public_key_openssh })
}

resource ibm_is_floating_ip drone {
  name   = "drone-server-${data.ibm_is_zones.regional_zones.zones[0]}-fip"
  target = ibm_is_instance.drone.primary_network_interface[0].id
}

resource "local_file" "ssh-key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "ansible/generated_key_rsa"
  file_permission = "0600"
}

resource "digitalocean_record" "drone" {
  domain = data.digitalocean_domain.drone.name
  type   = "A"
  name   = var.project
  value  = ibm_is_floating_ip.drone.address
}

module ansible {
  source        = "./ansible"
  drone_address = ibm_is_floating_ip.drone.address
}