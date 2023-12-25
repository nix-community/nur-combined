# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Lin Yinfeng <lin.yinfeng@outlook.com>
#
# SPDX-License-Identifier: MIT

resource "tailscale_dns_preferences" "sane_defaults" {
  magic_dns = true
}

resource "tailscale_tailnet_key" "r1e0p1" {
  reusable      = true
  ephemeral     = false
  preauthorized = true

  tags = ["tag:infra"]

  lifecycle {
    replace_triggered_by = [
      time_static.rotate_monthly
    ]
  }
}

resource "tailscale_tailnet_key" "r1e1p1" {
  reusable      = true
  ephemeral     = true
  preauthorized = true

  tags = ["tag:infra"]

  lifecycle {
    replace_triggered_by = [
      time_static.rotate_monthly
    ]
  }
}
