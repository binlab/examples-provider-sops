terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
    sops = {
      source  = "registry.terraform.io/binlab/sops"
      version = "1.4.0"
    }
  }
}
