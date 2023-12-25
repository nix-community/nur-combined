# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.13.11"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.2"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

data "sops_file" "tailscale" {
  source_file = "../../secrets/infrastructure/terraform/tailscale.yaml"
}

provider "tailscale" {
  api_key             = null
  tailnet             = data.sops_file.tailscale.data["tailnet"]
  base_url            = data.sops_file.tailscale.data["base_url"]
  oauth_client_id     = data.sops_file.tailscale.data["oauth_client_id"]
  oauth_client_secret = data.sops_file.tailscale.data["oauth_client_secret"]
  user_agent          = "Tailscale / ~> 0.13.11 (Terraform Provider)"
}
