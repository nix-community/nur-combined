terraform {
    cloud {
        organization = "lucasew"
        workspaces {
            name = "infra"
        }
    }
}

variable "gcp_zone" {
    type = string
    default = "us-central1-a"
    description = "Zona do GCP pra subir as coisas"
}

variable "gcp_project" {
    type = string
    default = "artimanhas-do-lucaum"
    description = "Projeto que tudo pertence"
}

variable "gcp_token" {
    type = string
    sensitive = true
    description = "Token GCP"
}

resource "google_compute_instance" "vps" {
  name = "vps"

  attached_disk {
    device_name = "persist"
    mode        = "READ_WRITE"
    source      = google_compute_disk.persist.self_link
  }

  boot_disk {
    auto_delete = false
    source = google_compute_disk.nixos_rootfs.self_link
  }

  confidential_instance_config {
    enable_confidential_compute = false
  }

  enable_display = true
  machine_type   = "e2-micro"
  /* guest_accelerator { */
  /*   type = "nvidia-tesla-k80" */
  /*   count = 1 */
  /* } */
  scheduling {
    preemptible = true
    automatic_restart = false
    provisioning_model  = "SPOT"
  }

  metadata = {
    serial-port-enable = "true"
  }


  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    network = google_compute_network.vps.self_link
  }

  project = var.gcp_project

  service_account {
    email = google_service_account.service_account.email
    scopes = [ 
        "cloud-platform",
    ]
  }

  zone = var.gcp_zone
}
# terraform import google_compute_instance.vps vps

provider "google" {
    project = var.gcp_project
    zone = var.gcp_zone
    credentials = var.gcp_token
}

resource "google_service_account" "service_account" {
  account_id   = "lucasew-operator"


  display_name = "Compute Engine default service account"
  project      = var.gcp_project
}
# terraform import google_service_account.artimanhas-do-lucaum 178195340338-compute@developer.gserviceaccount.com

resource "google_compute_disk" "nixos_rootfs" {
  image                     = google_compute_image.nixos_bootstrap.self_link
  name                      = "nixos-rootfs"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = 20
  type                      = "pd-standard"
  zone                      = "us-central1-a"
}
# terraform import google_compute_disk.nixos_rootfs projects/artimanhas-do-lucaum/zones/us-central1-a/disks/nixos-rootfs


resource "google_compute_disk" "persist" {
  name                      = "persist"
  physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = 10
  type                      = "pd-standard"
  zone                      = "us-central1-a"
}
# terraform import google_compute_disk.persist projects/artimanhas-do-lucaum/zones/us-central1-a/disks/persist

resource "google_storage_bucket" "nixos_bootstrap" {
  force_destroy               = false
  location                    = "US-CENTRAL1"
  name                        = "nixos-bootstrap"
  project                     = var.gcp_project
  /* public_access_prevention    = "enforced" */
  storage_class               = "ARCHIVE"
  uniform_bucket_level_access = true
}
# terraform import google_storage_bucket.nixos_bootstrap nixos-bootstrap

resource "google_compute_image" "nixos_bootstrap" {
  disk_size_gb = 5
  family       = "nixos-77ea5e9cf0d1aa73f2fafacdbd1673c4b7dc8378"
  name         = "nixos-bootstrap"
  project      = var.gcp_project
}
# terraform import google_compute_image.nixos_bootstrap projects/artimanhas-do-lucaum/global/images/nixos-bootstrap


resource "google_compute_firewall" "www" {
  name          = "www"
  description   = "Libera acesso web"

  network       = google_compute_network.vps.self_link

  allow {
    ports    = ["80", "443"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}
# terraform import google_compute_firewall.www projects/artimanhas-do-lucaum/global/firewalls/www

resource "google_compute_firewall" "zerotier" {
  name          = "zerotier"
  description   = "Zerotier"

  network       = google_compute_network.vps.self_link

  allow {
    ports    = ["9993"]
    protocol = "udp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp" {
  name          = "icmp"
  description   = "Aceitar pings"

  network       = google_compute_network.vps.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_network" "vps" {
    name = "vps"
}

