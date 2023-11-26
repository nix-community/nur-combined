# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

variable "state_bucket_storage_class" {
  type        = string
  default     = "REGIONAL"
  description = "The storage class of the State bucket. Defaults to REGIONAL."
}
