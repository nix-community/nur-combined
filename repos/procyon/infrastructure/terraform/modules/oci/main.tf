# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

# Network

resource "random_pet" "vcn_dns_label" {
  length = 1
}

module "vcn" {
  source                   = "oracle-terraform-modules/vcn/oci"
  compartment_id           = data.sops_file.oci.data["tenancy_ocid"]
  create_nat_gateway       = true
  create_service_gateway   = true
  create_internet_gateway  = true
  lockdown_default_seclist = true
  vcn_name                 = "Default VCN"
  vcn_cidrs                = ["${var.vcn_cidr}"]
  vcn_dns_label            = random_pet.vcn_dns_label.id
}

resource "oci_core_security_list" "tailscale" {
  display_name   = "Tailscale"
  vcn_id         = module.vcn.vcn_id
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  ingress_security_rules {
    protocol    = 17
    stateless   = true
    source      = "0.0.0.0/0"
    description = "Tailscale IPv4 direct connections"

    udp_options {
      min = 41641
      max = 41641
    }
  }
}

resource "random_pet" "public_dns_label" {
  length = 1
}

resource "oci_core_subnet" "public" {
  display_name      = "Public Subnet"
  vcn_id            = module.vcn.vcn_id
  route_table_id    = module.vcn.ig_route_id
  dns_label         = random_pet.public_dns_label.id
  security_list_ids = [module.vcn.default_security_list_id]
  compartment_id    = data.sops_file.oci.data["tenancy_ocid"]
  cidr_block        = cidrsubnet(var.vcn_cidr, var.newbits["public"], var.netnum["public"])
}

resource "random_pet" "private_dns_label" {
  length = 1
}

resource "oci_core_subnet" "private" {
  display_name      = "Private Subnet"
  vcn_id            = module.vcn.vcn_id
  route_table_id    = module.vcn.nat_route_id
  dns_label         = random_pet.private_dns_label.id
  security_list_ids = [module.vcn.default_security_list_id]
  compartment_id    = data.sops_file.oci.data["tenancy_ocid"]
  cidr_block        = cidrsubnet(var.vcn_cidr, var.newbits["private"], var.netnum["private"])
}
