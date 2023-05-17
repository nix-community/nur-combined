# adapted from https://github.com/hashicorp/terraform-provider-kubernetes/blob/main/kubernetes/test-infra/gke/main.tf

terraform {
  cloud {
    organization = "lucasew"
    workspaces {
      name = "gke"
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
    default = "us-central1-a"
    description = "Zona do GCP pra subir as coisas"
}

variable "cluster_size" {
  type = number
  default = 1
  description = "Tamanho da familia"
}

variable "gcp_project" {
    type = string
    default = "artimanhas-do-lucaum"
    description = "Projeto que tudo pertence"
}

variable "gcp_instance" {
  type = string
  default = "e2-micro"
  description = "Qual instancia usar"
}


variable "gcp_token" {
    type = string
    sensitive = true
    description = "Token GCP"
}

variable "kubernetes_version" {
  default = ""
}

provider "google" {
    project = var.gcp_project
    zone = var.gcp_zone
    # credentials = file("/tmp/artimanhas-do-lucaum-4152360065eb.json")
    credentials = var.gcp_token
}

resource "google_service_account" "default" {
  display_name = "GKE service account"
  project      = var.gcp_project
  account_id   = "kubernetes-gke"
}

data "google_container_engine_versions" "supported" {
  location = var.gcp_zone
  version_prefix = var.kubernetes_version
}

resource "google_container_cluster" "primary" {
  # provider = google-beta
  name = "clusterson"
  location = var.gcp_zone
  node_version = data.google_container_engine_versions.supported.latest_node_version
  min_master_version = data.google_container_engine_versions.supported.latest_master_version

  service_external_ips_config {
    enabled = true
  }

  initial_node_count = 1
  node_config {
    machine_type = var.gcp_instance
    service_account = google_service_account.default.email
    spot = true
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}

locals {
  kubeconfig = {
    apiVersion = "v1"
    kind       = "Config"
    preferences = {
      colors = true
    }
    current-context = google_container_cluster.primary.name
    contexts = [
      {
        name = google_container_cluster.primary.name
        context = {
          cluster   = google_container_cluster.primary.name
          user      = google_service_account.default.email
          namespace = "default"
        }
      }
    ]
    clusters = [
      {
        name = google_container_cluster.primary.name
        cluster = {
          server                     = "https://${google_container_cluster.primary.endpoint}"
          certificate-authority-data = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
        }
      }
    ]
    users = [
      {
        name = google_service_account.default.email
        user = {
          exec = {
            apiVersion         = "client.authentication.k8s.io/v1beta1"
            command            = "gke-gcloud-auth-plugin"
            interactiveMode    = "Never"
            provideClusterInfo = true
          }
        }
      }
    ]
  }
}

output "kubeconfig" {
  value = yamlencode(local.kubeconfig)
}

output "node_version" {
  value = google_container_cluster.primary.node_version
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}
