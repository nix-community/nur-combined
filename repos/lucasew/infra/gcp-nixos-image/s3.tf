terraform {
  cloud {
    organization = "lucasew"
    workspaces {
      name = "gcp-nixos-image"
    }
  }
  required_providers {
      google = {
      source = "hashicorp/google"
      version = "4.65.2"
    }
  }
}


variable "gcp_zone" {
    type = string
    default = "US-CENTRAL1" # Iowa https://cloud.google.com/storage/docs/locations?hl=pt-br#location-r
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

variable "gcp_bucket_name" {
  type = string
  default = "lucasew_nixos_images"
}

provider "google" {
    project = var.gcp_project
    zone = var.gcp_zone
    # credentials = file("/tmp/artimanhas-do-lucaum-4152360065eb.json")
    credentials = var.gcp_token
}

resource "google_service_account" "default" {
  display_name = "S3 NixOS image service account"
  project      = var.gcp_project
  account_id   = "nixos-image-s3"
}

resource "google_storage_bucket" "default" {
  name = var.gcp_bucket_name
  storage_class = "STANDARD"
  versioning {
    enabled = false
  }
  location = var.gcp_zone
  project = var.gcp_project
}
