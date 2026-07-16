# =============================================
# Key Pair — Terraform tự upload lên AWS
# =============================================
resource "aws_key_pair" "swarm_key" {
  key_name   = "swarm-key"
  public_key = file(var.pub_key_path)
}

# =============================================
# EC2: Swarm Manager
# =============================================

# Note: Kiến trúc chuẩn Docker Swarm
# + Manager node: bạn đặt trong public subnet, có public IP. SSH trực tiếp từ máy local vào manager qua public IP.
# + Worker node: bạn đặt trong private subnet, không có public IP. Bạn không SSH trực tiếp từ Internet vào worker, ssh vào manager rồi từ manager SSH vào worker.
                                                                #Worker node chỉ chạy container app thật, không điều phối swarm.

resource "aws_instance" "swarm_manager" {
  ami                         = var.amis[var.aws_region]
  instance_type               = var.manager_instance_type
  subnet_id                   = aws_subnet.swarm_manager_subnet.id #public subnet
  availability_zone           = var.zones[0]
  key_name                    = aws_key_pair.swarm_key.key_name
  vpc_security_group_ids      = [aws_security_group.manager_sg.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo docker swarm init --advertise-addr ${self.private_ip}"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_users[var.aws_region]
      private_key = file(var.pri_key_path)
      host        = self.public_ip
    }
  }

  tags = { Name = "swarm-manager", Role = "manager" }
}

#Elastic IP cho manager node, để SSH vào manager node không bị thay đổi IP public
resource "aws_eip" "manager_eip" {
  domain   = "vpc"
  instance = aws_instance.swarm_manager.id

  # Đảm bảo EIP gắn sau khi instance tạo xong
  depends_on = [aws_instance.swarm_manager]

  tags = {
    Name = "swarm-manager-eip"
  }
}

# Đoạn code này tạo một ổ EBS 10GB và gắn nó vào EC2 manager node tại /dev/xvdh.
resource "aws_ebs_volume" "manager_vol" {
  availability_zone = var.zones[0]
  size              = 10
  tags = { Name = "swarm-manager-vol" }
}

resource "aws_volume_attachment" "manager_vol_attach" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.manager_vol.id
  instance_id = aws_instance.swarm_manager.id
}

# =============================================
# EC2: Swarm Workers (count = 2)
# =============================================
resource "aws_instance" "swarm_worker" {
  count                       = 2
  ami                         = var.amis[var.aws_region]
  instance_type               = var.worker_instance_type
  # private subnet, không có public IP, SSH vào worker phải đi qua manager
  subnet_id                   = count.index == 0 ? aws_subnet.swarm_worker_subnet_1.id : aws_subnet.swarm_worker_subnet_2.id 
  availability_zone           = var.zones[count.index + 1]
  key_name                    = aws_key_pair.swarm_key.key_name
  vpc_security_group_ids      = [aws_security_group.worker_sg.id]
  associate_public_ip_address = false # worker chỉ có private IP

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo systemctl enable docker",
      "sudo systemctl start docker"
    ]
    connection {
      type        = "ssh"
      user        = var.ssh_users[var.aws_region]
      private_key = file(var.pri_key_path)
      host        = self.private_ip   
      # worker chỉ có private IP + manager node chính là bastion host => SSH vào worker phải đi qua manager node
      # bastion_host        = aws_instance.swarm_manager.public_ip #public-ip của manager node
      bastion_host = aws_eip.manager_eip.public_ip          # ← EIP cố định
      bastion_user        = var.ssh_users[var.aws_region]
      bastion_private_key = file(var.pri_key_path)
    }
  }

  tags = {
    Name = "swarm-worker-${count.index + 1}"
    Role = "worker"
  }
}

# =============================================
# EC2: NFS Server
# =============================================
resource "aws_instance" "nfs" {
  ami                         = var.amis[var.aws_region]
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.nfs_subnet.id
  availability_zone           = var.zones[0]
  key_name                    = aws_key_pair.swarm_key.key_name
  vpc_security_group_ids      = [aws_security_group.nfs_sg.id]
  associate_public_ip_address = false

  provisioner "remote-exec" {
    inline = ["sudo apt-get update -y"]
    connection {
      type        = "ssh"
      user        = var.ssh_users[var.aws_region]
      private_key = file(var.pri_key_path)
      host        = self.private_ip
      bastion_host = aws_eip.manager_eip.public_ip          # ← EIP cố định
      bastion_user        = var.ssh_users[var.aws_region]
      bastion_private_key = file(var.pri_key_path)
    }
  }

  tags = { Name = "nfs-server", Role = "nfs" }
}

# EBS volume cho NFS storage => với NFS rất cần thiết
resource "aws_ebs_volume" "nfs_vol" {
  availability_zone = var.zones[0]
  size              = 20 # Prometheus data 15 ngày ~5GB + dư => nên không cần
  tags = { Name = "nfs-storage" }
}

resource "aws_volume_attachment" "nfs_vol_attach" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.nfs_vol.id
  instance_id = aws_instance.nfs.id
}

# =============================================
# EC2: Monitoring (Prometheus + Grafana)
# =============================================
resource "aws_instance" "monitoring" {
  ami                         = var.amis[var.aws_region]
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.monitoring_subnet.id
  availability_zone           = var.zones[0]
  key_name                    = aws_key_pair.swarm_key.key_name
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]
  associate_public_ip_address = false

  provisioner "remote-exec" {
    inline = ["sudo apt-get update -y"]
    connection {
      type        = "ssh"
      user        = var.ssh_users[var.aws_region]
      private_key = file(var.pri_key_path)
      host        = self.private_ip
      bastion_host = aws_eip.manager_eip.public_ip          # ← EIP cố định
      bastion_user        = var.ssh_users[var.aws_region]
      bastion_private_key = file(var.pri_key_path)
    }
  }

  tags = { Name = "monitoring", Role = "monitoring" }
}