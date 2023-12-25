# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
#
# SPDX-License-Identifier: MIT

locals {
  ssh_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMLMCpAHL6U/68APRbekm/mzlBaRSNzi3GQzJYff0N69"
  name = {
    arm_0 = "oci-armcore"
    amd_1 = "oci-amdcore"
    amd_2 = "oci-amdside"
  }
  shape = {
    arm = "VM.Standard.A1.Flex"
    amd = "VM.Standard.E2.1.Micro"
  }
}

data "oci_identity_availability_domain" "ad" {
  ad_number      = 1
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]
}

data "oci_core_images" "amd" {
  sort_order               = "DESC"
  sort_by                  = "TIMECREATED"
  shape                    = local.shape.amd
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04 Minimal"
  compartment_id           = data.sops_file.oci.data["tenancy_ocid"]
}

data "oci_core_images" "arm" {
  sort_order               = "DESC"
  sort_by                  = "TIMECREATED"
  shape                    = local.shape.arm
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04 Minimal aarch64"
  compartment_id           = data.sops_file.oci.data["tenancy_ocid"]
}

data "oci_core_instances" "running" {
  state               = "RUNNING"
  compartment_id      = data.sops_file.oci.data["tenancy_ocid"]
  availability_domain = data.oci_identity_availability_domain.ad.name
}

# BEGIN: ***
# Instances
#

resource "oci_core_instance" "arm_0" {
  count                               = 0
  is_pv_encryption_in_transit_enabled = true
  shape                               = local.shape.arm
  display_name                        = local.name.arm_0
  compartment_id                      = data.sops_file.oci.data["tenancy_ocid"]
  availability_domain                 = data.oci_identity_availability_domain.ad.name

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.private.id
  }

  source_details {
    boot_volume_size_in_gbs = 100
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.arm.images[0], "id")
  }

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  metadata = {
    ssh_authorized_keys = local.ssh_key
    user_data = base64encode(templatefile("${path.module}/files/cloud-init.yaml", {
      TAILSCALE_EXIT_NODE = false
      SSH_AUTHORIZED_KEYS = local.ssh_key
      INSTANCE_HOSTNAME   = local.name.arm_0
      TAILSCALE_AUTHKEY   = var.tailscale_tailnet_key
      TAILSCALE_ROUTES    = ""
    }))
  }
}

resource "oci_core_instance" "amd_1" {
  count                               = 0
  is_pv_encryption_in_transit_enabled = true
  shape                               = local.shape.amd
  display_name                        = local.name.amd_1
  compartment_id                      = data.sops_file.oci.data["tenancy_ocid"]
  availability_domain                 = data.oci_identity_availability_domain.ad.name

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.private.id
    nsg_ids          = [oci_core_network_security_group.tailscale.id]
  }

  source_details {
    boot_volume_size_in_gbs = 50
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.amd.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = local.ssh_key
    user_data = base64encode(templatefile("${path.module}/files/cloud-init.yaml", {
      TAILSCALE_EXIT_NODE = false
      SSH_AUTHORIZED_KEYS = local.ssh_key
      INSTANCE_HOSTNAME   = local.name.amd_1
      TAILSCALE_AUTHKEY   = var.tailscale_tailnet_key
      TAILSCALE_ROUTES    = ""
    }))
  }
}

resource "oci_core_instance" "amd_2" {
  count                               = 0
  is_pv_encryption_in_transit_enabled = true
  shape                               = local.shape.amd
  display_name                        = local.name.amd_2
  compartment_id                      = data.sops_file.oci.data["tenancy_ocid"]
  availability_domain                 = data.oci_identity_availability_domain.ad.name

  create_vnic_details {
    assign_public_ip = false
    subnet_id        = oci_core_subnet.private.id
    nsg_ids          = [oci_core_network_security_group.mosh.id]
  }

  source_details {
    boot_volume_size_in_gbs = 50
    source_type             = "image"
    source_id               = lookup(data.oci_core_images.amd.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = local.ssh_key
    user_data = base64encode(templatefile("${path.module}/files/cloud-init.yaml", {
      TAILSCALE_EXIT_NODE = true
      SSH_AUTHORIZED_KEYS = local.ssh_key
      INSTANCE_HOSTNAME   = local.name.amd_2
      TAILSCALE_AUTHKEY   = var.tailscale_tailnet_key
      TAILSCALE_ROUTES    = "${oci_core_subnet.private.cidr_block},169.254.169.254/32"
    }))
  }
}

#
# Instances
# END: ***
