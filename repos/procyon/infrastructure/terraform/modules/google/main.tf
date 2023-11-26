# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

resource "random_id" "state_bucket" {
  byte_length = 4
}

resource "random_pet" "state_bucket" {
  length = 1
}

resource "google_storage_bucket" "state_bucket" {
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  storage_class               = var.state_bucket_storage_class
  location                    = upper(data.sops_file.google.data["region"])
  name                        = "${random_pet.state_bucket.id}-${random_id.state_bucket.hex}"

  versioning {
    enabled = true
  }
}
