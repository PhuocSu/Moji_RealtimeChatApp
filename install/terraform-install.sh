# Cài gói hỗ trợ
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

# Thêm GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Thêm repository HashiCorp
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update và cài Terraform
sudo apt update
sudo apt install terraform -y

# Kiểm tra phiên bản
terraform -version
