# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.21.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }
}

data "sops_file" "oci" {
  source_file = "../../secrets/infrastructure/terraform/oracle.yaml"
}

provider "oci" {
  disable_auto_retries = true
  region               = data.sops_file.oci.data["region"]
  user_ocid            = data.sops_file.oci.data["user_ocid"]
  fingerprint          = data.sops_file.oci.data["fingerprint"]
  private_key          = data.sops_file.oci.data["rsa_private"]
  tenancy_ocid         = data.sops_file.oci.data["tenancy_ocid"]
}
