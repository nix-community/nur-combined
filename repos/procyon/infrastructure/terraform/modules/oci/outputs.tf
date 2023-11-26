# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

# Network

output "module_vcn_ids" {
  description = "Network Outputs"
  value = {
    vcn_id                       = module.vcn.vcn_id
    vcn_dns_label                = module.vcn.vcn_all_attributes.dns_label
    nat_gateway_id               = module.vcn.nat_gateway_id
    service_gateway_id           = module.vcn.service_gateway_id
    internet_gateway_id          = module.vcn.internet_gateway_id
    nat_gateway_route_id         = module.vcn.nat_route_id
    internet_gateway_route_id    = module.vcn.ig_route_id
    vcn_default_route_table_id   = module.vcn.vcn_all_attributes.default_route_table_id
    vcn_default_dhcp_options_id  = module.vcn.vcn_all_attributes.default_dhcp_options_id
    vcn_default_security_list_id = module.vcn.vcn_all_attributes.default_security_list_id
  }
}
