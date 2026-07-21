# =============================================
# Security Group: Swarm
# =============================================

#1. Manager node
resource "aws_security_group" "manager_sg" {
  name        = "swarm-manager-sg"
  description = "Security group cho Docker Swarm"
  vpc_id      = aws_vpc.docker-swarm.id  # giống với VPC được tạo trong vpc.tf

  ingress { # ingress = inbound (traffic đi vào EC2)    
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["42.117.110.206/32"] #0.0.0.0/0: bất kể Ip nào trên local cũng được ssh, quality gate báo lỗi => modem người khác nên không để ip tĩnh được
    #tất nhiên, mức độ an toàn sẽ thấp => đổi lại không cần terraform apply sau mỗi lần IP thay đổi
    #var.my_ip: chỉ cho phép IP của bạn SSH vào
  }

  ingress {
    description = "Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # mở cho toàn bộ Internet
  }

  ingress {
    description = "Backend API"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Swarm management"
    from_port   = 2377 # bắt buộc cho node manager để worker join cluster
    to_port     = 2377 
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # nên giới hạn trong VPC thay vì mở toàn Internet
  }

  ingress {
    description = "Swarm node TCP"
    from_port   = 7946 # bắt buộc cho communication giữa các node (TCP)
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Swarm node UDP"
    from_port   = 7946 # bắt buộc cho communication giữa các node (UDP)
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Swarm overlay"
    from_port   = 4789 # bắt buộc cho overlay network (container‑to‑container traffic)
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Để dễ dàng truy cập từ local
  ingress {
    description = "Prometheus (proxy qua manager)"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana (proxy qua manager)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Thêm mới — dùng cidr_blocks thay security_groups để tránh cycle
  ingress {
    description = "Node Exporter from monitoring"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.5.0/24"] # monitoring subnet (chung)
  }

  ingress {
    description = "Docker metrics from monitoring"
    from_port   = 9323
    to_port     = 9323
    protocol    = "tcp"
    cidr_blocks = ["10.0.5.0/24"] # monitoring subnet
  }


  egress { # outbound (traffic đi ra khỏi EC2)
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # cho phép tất cả các giao thức (TCP, UDP, ICMP, v.v.)
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "swarm-manager-sg"
  }
}

#2. Worker node
resource "aws_security_group" "worker_sg" {
  name        = "swarm-worker-sg"
  description = "Security group for Swarm Worker"
  vpc_id      = aws_vpc.docker-swarm.id

  ingress {
    description     = "SSH from Manager"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.manager_sg.id]
  }

  ingress {
    description = "Node Exporter from monitoring"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.5.0/24"] # monitoring subnet
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "swarm-worker-sg" }
}

# nfs
resource "aws_security_group" "nfs_sg" {
  name        = "nfs-sg"
  description = "Security group for nfs"
  vpc_id      = aws_vpc.docker-swarm.id

  ingress {
    description     = "SSH from Manager"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.manager_sg.id]  # chỉ cho manager SSH vào
  }

  ingress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]   # chỉ trong VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nfs-sg" }
}

# monitoring
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-sg"
  description = "Security group for monitoring"
  vpc_id      = aws_vpc.docker-swarm.id

  ingress {
    description     = "SSH from Manager"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.manager_sg.id]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]   # chỉ trong VPC
  }

  ingress {
    description = "AlertManager"
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "monitoring_sg" }
}

