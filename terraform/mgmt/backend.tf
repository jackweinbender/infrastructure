terraform {
  backend "s3" {
    bucket = "tf-backend-61rckk"
    key    = "terraform-mgmt.tfstate"
    region = "us-east-1"
  }
}