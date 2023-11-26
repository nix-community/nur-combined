# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

data "sops_file" "google" {
  source_file = "../../secrets/infrastructure/terraform/google.yaml"
}

data "sops_file" "service_account" {
  source_file = "../../secrets/infrastructure/terraform/google.json"
}

provider "google" {
  zone        = data.sops_file.google.data["zone"]
  region      = data.sops_file.google.data["region"]
  project     = data.sops_file.google.data["project"]
  credentials = data.sops_file.service_account.raw
}
