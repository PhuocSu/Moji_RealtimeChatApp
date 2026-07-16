# Sarm manager and workers node
# output "manager_public_ip" {
#   value = aws_instance.swarm_manager.public_ip
# }
# Thay vì dùng cái trên, ta dùng:
output "manager_public_ip" {
  description = "EIP cố định của manager — không đổi dù restart"
  value       = aws_eip.manager_eip.public_ip
}

output "worker_private_ips" {
  value = aws_instance.swarm_worker[*].private_ip
}

output "ssh_manager" {
  value = "ssh -i ${var.pri_key_path} ${var.ssh_users[var.aws_region]}@${aws_eip.manager_eip.public_ip}"
}


# NFS và monitoring
output "nfs_private_ip" {
  value = aws_instance.nfs.private_ip
}

output "monitoring_private_ip" {
  value = aws_instance.monitoring.private_ip
}