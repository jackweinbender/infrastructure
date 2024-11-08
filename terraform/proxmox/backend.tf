terraform {
  backend "s3" {
    bucket = "tf-backend-61rckk"
    key    = "terraform-proxmox.tfstate"
    region = "us-east-1"
  }
}
