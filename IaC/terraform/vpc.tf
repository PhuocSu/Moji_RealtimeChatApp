# VPC chính
resource "aws_vpc" "docker-swarm" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true 
  enable_dns_support   = true
  tags = { Name = "docker-swarm-vpc" }
}

# Internet Gateway cho public subnet
resource "aws_internet_gateway" "docker-swarm-igw" {
  vpc_id = aws_vpc.docker-swarm.id
  tags   = { Name = "docker-swarm-igw" }
}

# Route Table cho public subnet
resource "aws_route_table" "docker-swarm-public-rt" {
  vpc_id = aws_vpc.docker-swarm.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker-swarm-igw.id
  }
  tags = { Name = "docker-swarm-public-rt" }
}

# Public Subnet cho Manager
resource "aws_subnet" "swarm_manager_subnet" {
  vpc_id                  = aws_vpc.docker-swarm.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = { Name = "swarm-manager-subnet" }
}

# Private Subnet cho Worker
resource "aws_subnet" "swarm_worker_subnet_1" {
  vpc_id            = aws_vpc.docker-swarm.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  tags = { Name = "swarm-worker-subnet-1" }
}

resource "aws_subnet" "swarm_worker_subnet_2" {
  vpc_id            = aws_vpc.docker-swarm.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-southeast-1c"
  tags = { Name = "swarm-worker-subnet-2" }
}

# Gắn manager subnet với public route table
resource "aws_route_table_association" "manager_assoc" {
  subnet_id      = aws_subnet.swarm_manager_subnet.id
  route_table_id = aws_route_table.docker-swarm-public-rt.id
}

# Elastic IP cho NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway để worker subnet ra Internet
resource "aws_nat_gateway" "docker-swarm-nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.swarm_manager_subnet.id
  tags = { Name = "docker-swarm-nat" }
}

# Route Table cho worker subnet
resource "aws_route_table" "docker-swarm-private-rt" {
  vpc_id = aws_vpc.docker-swarm.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.docker-swarm-nat.id
  }
  tags = { Name = "docker-swarm-private-rt" }
}

# Gắn worker subnet với private route table
resource "aws_route_table_association" "worker_assoc1" {
  subnet_id      = aws_subnet.swarm_worker_subnet_1.id
  route_table_id = aws_route_table.docker-swarm-private-rt.id
}
resource "aws_route_table_association" "worker_assoc2" {
  subnet_id      = aws_subnet.swarm_worker_subnet_2.id
  route_table_id = aws_route_table.docker-swarm-private-rt.id
}
