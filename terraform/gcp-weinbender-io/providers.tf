provider "google" {
  project = "weinbender-io"
  region  = "us-central1"
}

data "google_client_config" "current" {}
