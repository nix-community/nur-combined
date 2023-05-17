terraform {
    cloud {
        organization = "lucasew"
        workspaces {
            name = "infra"
        }
    }
    required_providers {
      zerotier = {
        source = "zerotier/zerotier"
        version = "1.2.0"
      }
    }
}
