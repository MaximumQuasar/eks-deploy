terraform {
  backend "s3" {
    bucket = "tf-backend-storage"
    region = "us-east-1"
    key    = "state/terraform.tfstate"
  }
}