# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

output "tailscale_tailnet_key-r1e0p1" {
  sensitive = true
  value     = module.tailscale.tailnet_key-r1e0p1
}

output "tailscale_tailnet_key-r1e1p1" {
  sensitive = true
  value     = module.tailscale.tailnet_key-r1e1p1
}
