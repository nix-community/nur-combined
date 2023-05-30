terraform {
  cloud {
    organization = "lucasew"
    workspaces {
      name = "turbo"
    }
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.65.2"
    }
  }
}

variable "gcp_instance_image" {
  type = string
  description = "Caminho da imagem usada na instância"
  default = "ml-images/c2-deeplearning-pytorch-1-13-cu113-v20230501-debian-10-py37"
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

variable "gcp_turbo_stop" {
    type = bool
    description = "Stop turbo instance?"
    default = true
}

variable "gcp_turbo_modo_turbo" {
  type = bool
  default = false
  description = "VPS com mais CPU e GPU"
}

variable "gcp_service_account_id" {
  type = string
  default = "turbo-instance"
  description = "Service account id da conta"
}

variable "gcp_turbo_gpu" {
  type = string
  default = "nvidia-tesla-t4"
  # default = "nvidia-tesla-k80"
  description = "Que gpu usar"
}

variable "gcp_turbo_instance" {
  type = string
  default = "n1-highcpu-4"
  description = "Qual instancia usar no modo turbo"
}

variable "gcp_turbo_disk_size" {
  type = number
  default = 20
  description = "Tamanho do rootfs da instancia"
}

provider "google" {
    project = var.gcp_project
    zone = var.gcp_zone
    # credentials = file("/tmp/artimanhas-do-lucaum-4152360065eb.json")
    credentials = var.gcp_token
}

resource "google_service_account" "service_account" {
  display_name = "Modo Turbo service account"
  project      = var.gcp_project
  account_id   = var.gcp_service_account_id
}

output "turbo-internal-ip" {
  value = length(google_compute_instance.turbo) > 0 ? google_compute_instance.turbo[0].network_interface.0.network_ip : ""
}

output "turbo-external-ip" {
  value = length(google_compute_instance.turbo) > 0 ? google_compute_instance.turbo[0].network_interface.0.access_config.0.nat_ip : ""
}


resource "google_compute_instance" "turbo" {
  name = "turbo"

  # attached_disk {
  #   device_name = "persist"
  #   mode        = "READ_WRITE"
  #   source      = data.google_compute_disk.persist.self_link
  # }

  boot_disk {
    auto_delete = false
    source = google_compute_disk.turbo_rootfs.self_link
  }

  confidential_instance_config {
    enable_confidential_compute = false
  }

  enable_display = true

  machine_type = var.gcp_turbo_modo_turbo ? var.gcp_turbo_instance : "e2-micro"

  count = var.gcp_turbo_stop ? 0 : 1

  guest_accelerator {
    type = var.gcp_turbo_gpu
    count = var.gcp_turbo_modo_turbo ? 1 : 0
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

    network = google_compute_network.turbo.self_link
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
# terraform import google_compute_instance.turbo turbo

resource "google_compute_disk" "turbo_rootfs" {
  image                     = var.gcp_instance_image
  name                      = "turbo-rootfs"
  # physical_block_size_bytes = 4096
  project                   = var.gcp_project
  size                      = var.gcp_turbo_disk_size
  type                      = "pd-standard"
  zone                      = var.gcp_zone
}
# terraform import google_compute_disk.nixos_rootfs projects/artimanhas-do-lucaum/zones/us-central1-a/disks/nixos-rootfs


# data "google_compute_disk" "persist" {
#   name                      = "persist"
# }
# # terraform import google_compute_disk.persist projects/artimanhas-do-lucaum/zones/us-central1-a/disks/persist

# resource "google_compute_image" "nixos_bootstrap" {
#   name = "nixos"
#   project      = var.gcp_project
#   raw_disk {
#     source = data.google_storage_bucket_object.nixos-image-bucket.self_link
#   }
# }

# data "google_storage_bucket_object" "nixos-image-bucket" {
#   name   = "nixos-image-lucasew:nixcfg-4b7b21ad0e11fd33133d31b43b7845609ddcfc63-x86_64-linux.raw.tar.gz"
#   bucket = "nixos-image-bootstrap"
# }



resource "google_compute_firewall" "www" {
  name          = "www-turbo"
  description   = "Libera acesso web"

  network       = google_compute_network.turbo.self_link

  allow {
    ports    = ["80", "443"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
  name          = "ssh-turbo"
  description   = "Libera acesso ssh"

  network       = google_compute_network.turbo.self_link

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }

  source_ranges = ["0.0.0.0/0"]
}
# terraform import google_compute_firewall.www projects/artimanhas-do-lucaum/global/firewalls/www

# resource "google_compute_firewall" "zerotier" {
#   name          = "zerotier"
#   description   = "Zerotier"

#   network       = google_compute_network.turbo.self_link

#   allow {
#     ports    = ["9993"]
#     protocol = "udp"
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

resource "google_compute_firewall" "icmp" {
  name          = "icmp-turbo"
  description   = "Aceitar pings"

  network       = google_compute_network.turbo.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_network" "turbo" {
    name = "turbo"
}

