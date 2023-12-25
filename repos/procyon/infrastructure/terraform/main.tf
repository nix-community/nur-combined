# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

terraform {
  required_version = "~> 1.6.3"

  cloud {
    organization = "procyonidae"

    workspaces {
      name = "snowy-burrow"
    }
  }
}

module "google" {
  source = "./modules/google"
}

module "oci" {
  source                = "./modules/oci"
  tailscale_tailnet_key = module.tailscale.tailnet_key-r1e0p1
}

module "tailscale" {
  source = "./modules/tailscale"
}
