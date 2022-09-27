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

resource "google_compute_instance" "ivarstead" {
  name = "ivarstead"

  attached_disk {
    device_name = "persist"
    mode        = "READ_WRITE"
    source      = data.google_compute_disk.persist.self_link
  }

  boot_disk {
    auto_delete = false
    source = google_compute_disk.nixos_rootfs.self_link
  }

  confidential_instance_config {
    enable_confidential_compute = false
  }

  enable_display = true

  machine_type = var.gcp_ivarstead_modo_turbo ? "n1-highcpu-4" : "e2-micro"

  count = var.gcp_ivarstead_stop ? 0 : 1

  guest_accelerator {
    type = "nvidia-tesla-k80"
    count = var.gcp_ivarstead_modo_turbo ? 1 : 0
  }

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
# terraform import google_compute_instance.ivarstead ivarstead

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


data "google_compute_disk" "persist" {
  name                      = "persist"
}
# terraform import google_compute_disk.persist projects/artimanhas-do-lucaum/zones/us-central1-a/disks/persist

resource "google_compute_image" "nixos_bootstrap" {
  name = "nixos"
  project      = var.gcp_project
  raw_disk {
    source = data.google_storage_bucket_object.nixos-image-bucket.self_link
  }
}

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

