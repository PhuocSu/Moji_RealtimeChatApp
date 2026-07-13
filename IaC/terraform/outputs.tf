output "manager_public_ip" {
  value = aws_instance.swarm_manager.public_ip
}

output "worker_private_ips" {
  value = aws_instance.swarm_worker[*].private_ip
}

output "ssh_manager" {
  value = "ssh -i ${var.pri_key_path} ${var.ssh_users[var.aws_region]}@${aws_instance.swarm_manager.public_ip}"
}