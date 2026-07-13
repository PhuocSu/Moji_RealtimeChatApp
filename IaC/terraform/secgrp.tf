# =============================================
# Security Group
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
    cidr_blocks = [var.my_ip] # chỉ cho phép IP của bạn SSH vào
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "swarm-worker-sg" }
}