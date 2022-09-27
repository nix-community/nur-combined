

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

variable "gcp_ivarstead_stop" {
    type = bool
    description = "Stop ivarstead instance?"
    default = true
}

variable "gcp_ivarstead_modo_turbo" {
  type = bool
  default = false
  description = "VPS com mais CPU e GPU"
}

data "google_storage_bucket_object" "nixos-image-bucket" {
  name   = "nixos-image-lucasew:nixcfg-4b7b21ad0e11fd33133d31b43b7845609ddcfc63-x86_64-linux.raw.tar.gz"
  bucket = "nixos-bootstrap"
}


