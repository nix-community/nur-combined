# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

variable "disable_auto_retries" {
  type        = bool
  default     = false
  description = "Disable automatic retries for retriable errors. Automatic retries were introduced to solve some eventual consistency problems but it also introduced performance issues on destroy operations."
}

# https://datatracker.ietf.org/doc/html/rfc4632#section-3.1
variable "vcn_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The list of IPv4 CIDR blocks the VCN will use, as defined in RFC 4632 section 3.1."
}

# https://blog.ebfe.pw/posts/ipcalcterraform.html
variable "newbits" {
  type = map(any)
  default = {
    public  = 8
    private = 8
  }
  description = "`newbits` is the number of additional bits with which to extend the prefix. For example, if given a prefix ending in `/16` and a `newbits` value of `4`, the resulting subnet address will have length `/20`."
}

variable "netnum" {
  type = map(any)
  default = {
    public  = 0
    private = 1
  }
  description = "`netnum` is a whole number that can be represented as a binary integer with no more than `newbits` binary digits, which will be used to populate the additional bits added to the prefix."
}
