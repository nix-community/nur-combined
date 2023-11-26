# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

terraform {
  required_version = "~> 1.6.3"

  backend "gcs" {
    prefix = "workspaces"
    bucket = "ant-de17fa6d"
  }
}

module "google" {
  source = "./modules/google"
}

module "oci" {
  source = "./modules/oci"
}

module "tailscale" {
  source = "./modules/tailscale"
}
