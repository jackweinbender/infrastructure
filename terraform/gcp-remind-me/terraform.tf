terraform {
  backend "s3" {
    bucket = "tf-backend-61rckk"
    key    = "terraform-gcp-remind-me.tfstate"
    region = "us-east-1"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.14.1"
    }
  }
}
