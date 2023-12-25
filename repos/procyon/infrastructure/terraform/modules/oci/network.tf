# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

locals {
  anywhere      = "0.0.0.0/0"
  anywhere_ipv6 = "::/0"
}

data "oci_core_services" "all" {
  count = 1

  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# BEGIN: ***
# Route Tables
#

resource "oci_core_route_table" "internal" {
  display_name   = "Route Table (Internal)"
  vcn_id         = oci_core_vcn.default.id
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.default.id
  }

  route_rules {
    destination       = lookup(data.oci_core_services.all[0].services[0], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.default.id
  }
}

#
# Route Tables
# END: ***

# BEGIN: ***
# Security Lists
#

resource "oci_core_security_list" "private" {
  display_name   = "Security List (Private)"
  vcn_id         = oci_core_vcn.default.id
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  egress_security_rules {
    protocol         = "all"
    destination      = local.anywhere
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "1"
    source   = local.anywhere

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  dynamic "ingress_security_rules" {
    for_each = oci_core_vcn.default.cidr_blocks
    iterator = vcn_cidr
    content {
      protocol = "6"
      source   = vcn_cidr.value

      tcp_options {
        min = 22
        max = 22
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = oci_core_vcn.default.cidr_blocks
    iterator = vcn_cidr
    content {
      protocol = "1"
      source   = vcn_cidr.value
      icmp_options {
        type = "3"
      }
    }
  }
}

#
# Security Lists
# END: ***

# BEGIN: ***
# Security Group
#

resource "oci_core_network_security_group" "tailscale" {
  display_name   = "tailscale"
  vcn_id         = oci_core_vcn.default.id
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
}

resource "oci_core_network_security_group_security_rule" "easy_nat" {
  protocol                  = 17
  stateless                 = true
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  description               = "Tailscale IPv4 direct connections"
  network_security_group_id = oci_core_network_security_group.tailscale.id

  udp_options {
    destination_port_range {
      min = 41641
      max = 41641
    }
  }
}

resource "oci_core_network_security_group" "mosh" {
  display_name   = "ssh"
  vcn_id         = oci_core_vcn.default.id
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
}

resource "oci_core_network_security_group_security_rule" "ssh_ingress" {
  protocol                  = 6
  stateless                 = true
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  description               = "Allow SSH connections through port 22666"
  network_security_group_id = oci_core_network_security_group.mosh.id

  tcp_options {
    destination_port_range {
      min = 22666
      max = 22666
    }
  }
}

resource "oci_core_network_security_group_security_rule" "mosh_ingress" {
  protocol                  = 17
  stateless                 = true
  direction                 = "INGRESS"
  source                    = "0.0.0.0/0"
  description               = "Allow UDP connections from the 60000-61000 range"
  network_security_group_id = oci_core_network_security_group.mosh.id

  udp_options {
    destination_port_range {
      min = 60000
      max = 61000
    }
  }
}

#
# Security Group
# END: ***

# BEGIN: ***
# Gateways
#

resource "oci_core_internet_gateway" "default" {
  vcn_id         = oci_core_vcn.default.id
  display_name   = "Default Internet Gateway"
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
}

resource "oci_core_nat_gateway" "default" {
  vcn_id         = oci_core_vcn.default.id
  display_name   = "Default NAT Gateway"
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
}

resource "oci_core_service_gateway" "default" {
  vcn_id         = oci_core_vcn.default.id
  display_name   = "Default Service Gateway"
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  services {
    service_id = lookup(data.oci_core_services.all[0].services[0], "id")
  }
}

#
# Gateways
# END: ***

# BEGIN: ***
# Default Resources
#

resource "oci_core_default_security_list" "default" {
  display_name               = "Security List (Public)"
  manage_default_resource_id = oci_core_vcn.default.default_security_list_id

  egress_security_rules {
    protocol         = "all"
    destination      = local.anywhere
    destination_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    protocol         = "all"
    destination      = local.anywhere_ipv6
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "1"
    source   = local.anywhere

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = local.anywhere_ipv6

    icmp_options {
      type = "3"
      code = "4"
    }
  }

  dynamic "ingress_security_rules" {
    for_each = oci_core_vcn.default.cidr_blocks
    iterator = vcn_cidr

    content {
      protocol = "1"
      source   = vcn_cidr.value

      icmp_options {
        type = "3"
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = oci_core_vcn.default.ipv6cidr_blocks
    iterator = vcn_cidr

    content {
      protocol = "1"
      source   = vcn_cidr.value

      icmp_options {
        type = "3"
      }
    }
  }
}

resource "oci_core_default_route_table" "default" {
  display_name               = "Route Table (External)"
  manage_default_resource_id = oci_core_vcn.default.default_route_table_id

  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.default.id
  }

  route_rules {
    destination       = local.anywhere_ipv6
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.default.id
  }
}

resource "oci_core_default_dhcp_options" "default" {
  display_name               = "Default DHCP Options"
  manage_default_resource_id = oci_core_vcn.default.default_dhcp_options_id

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = [oci_core_vcn.default.vcn_domain_name]
  }
}

#
# Default Resources
# END: ***

resource "oci_core_vcn" "default" {
  is_ipv6enabled = true
  dns_label      = "default"
  display_name   = "Default VCN"
  cidr_blocks    = ["10.0.0.0/16"]
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  lifecycle {
    ignore_changes = [defined_tags, dns_label, freeform_tags]
  }
}

resource "oci_core_subnet" "public" {
  prohibit_public_ip_on_vnic = false
  dns_label                  = "public"
  cidr_block                 = "10.0.0.0/24"
  display_name               = "Public Subnet"
  vcn_id                     = oci_core_vcn.default.id
  route_table_id             = oci_core_default_route_table.default.id
  security_list_ids          = [oci_core_default_security_list.default.id]
  compartment_id             = data.sops_file.oci.data["tenancy_ocid"]
}

resource "oci_core_subnet" "private" {
  prohibit_public_ip_on_vnic = true
  dns_label                  = "private"
  cidr_block                 = "10.0.1.0/24"
  display_name               = "Private Subnet"
  vcn_id                     = oci_core_vcn.default.id
  route_table_id             = oci_core_route_table.internal.id
  security_list_ids          = [oci_core_security_list.private.id]
  compartment_id             = data.sops_file.oci.data["tenancy_ocid"]
}
