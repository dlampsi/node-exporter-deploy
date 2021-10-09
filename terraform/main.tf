terraform {
  required_version = "= 1.0.8"

  backend "local" {
    path = "state/terraform.tfstate"
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}