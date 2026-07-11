#Khai báo provider cụ thể (ví dụ AWS).
#Đặt region, profile, alias.
#Khai báo required_version của Terraform (ví dụ >= 1.5.0).
#Khai báo backend (ví dụ S3 để lưu state).
#Khai báo required_providers (ví dụ AWS, Azure, GCP).

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Credentials đọc từ ~/.aws/credentials hoặc biến môi trường
  # KHÔNG hardcode access_key / secret_key vào đây
}
