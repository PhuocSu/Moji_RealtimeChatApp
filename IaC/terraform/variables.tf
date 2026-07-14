variable "aws_region" {
  default = "ap-southeast-1"
}

# variable "my_ip" {
#   description = "IP của bạn + /32, chạy: curl ifconfig.me"
#   type        = string
# }

variable "pub_key_path" {
  description = "Đường dẫn tới public key - upload lên AWS"
  default     = "~/.ssh/id_rsa.pub"
}

variable "pri_key_path" {
  description = "Đường dẫn tới private key - dùng để SSH vào EC2"
  default     = "~/.ssh/id_rsa"
}

# AMI map theo region — đổi region không cần sửa thủ công
variable "amis" {
  type = map(string)
  default = {
    "ap-southeast-1" = "ami-078c1149d8ad719a7"  # Ubuntu 22.04 Singapore
    "us-east-1"      = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 N.Virginia
  }
}

# SSH user map theo region (Ubuntu = "ubuntu", Amazon Linux = "ec2-user")
variable "ssh_users" {
  type = map(string)
  default = {
    "ap-southeast-1" = "ubuntu"
    "us-east-1"      = "ubuntu"
  }
}

# Availability Zones
variable "zones" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "manager_instance_type" {
  default = "t3.small"    # chỉ điều phối, không chạy app
}

variable "worker_instance_type" {
  default = "t3.medium"   # chạy container app thật
}
