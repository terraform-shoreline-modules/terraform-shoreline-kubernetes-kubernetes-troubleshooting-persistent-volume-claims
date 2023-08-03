terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "kubernetes_troubleshooting_failed_persistent_volume_claims" {
  source    = "./modules/kubernetes_troubleshooting_failed_persistent_volume_claims"

  providers = {
    shoreline = shoreline
  }
}