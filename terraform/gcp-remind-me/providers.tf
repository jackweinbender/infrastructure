provider "google" {
  project = "remind-me-481700"
  region  = "us-central1"
}

data "google_client_config" "current" {}