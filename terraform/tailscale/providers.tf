terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.1"
    }
  }
}

provider "tailscale" {
  api_key = var.tailscale_api_key
  tailnet = "jackweinbender.github"
}