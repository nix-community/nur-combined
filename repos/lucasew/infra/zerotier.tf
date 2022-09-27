# Still not the way I want because I can't setup the DNS stuff from terraform

provider "zerotier" {
  zerotier_central_token = var.zerotier_token
}

variable "zerotier_token" {
  type = string
  sensitive = true
  description = "Token zerotier"
}

# data "zerotier_network" "lucao" {
#   id = "e5cd7a9e1c857f07"
# }
resource "zerotier_network" "lucao" {
  name = "lucao terraform"
  description = "Administrado pelo terraform, quem invadir é tchola"
  assign_ipv4 = {
    zerotier = true
  }
  assignment_pool {
    start = "192.168.69.1"
    end = "192.168.69.254"
  }
  enable_broadcast = true
  private = true
  flow_rules = "accept;"
}

resource "zerotier_member" "whiterun-nixos" {
  name = "whiterun-nixos"
  member_id = "913563f66e"
  network_id = zerotier_network.lucao.id
  allow_ethernet_bridging = true
  ip_assignments = [ "192.168.69.1" ]
}

resource "zerotier_member" "riverwood-nixos" {
  name = "riverwood-nixos"
  member_id = "dc64cce7f6"
  network_id = zerotier_network.lucao.id
  ip_assignments = [ "192.168.69.2" ]
}
