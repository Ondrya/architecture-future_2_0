# outputs.tf

output "vpc_network_id" {
  description = "ID созданной VPC сети"
  value       = yandex_vpc_network.main.id
}

output "subnet_ids" {
  description = "ID подсетей по именам"
  value       = { for k, v in yandex_vpc_subnet.subnets : k => v.id }
}

output "vm_instances_ips" {
  description = "Публичные IP виртуальных машин"
  value       = { for k, v in yandex_compute_instance.vms : k => v.network_interface[0].nat_ip_address }
}

output "generated_ssh_private_key" {
  description = "SSH ключ для подключения к ВМ (чувствительный)"
  value       = tls_private_key.vm_ssh_key.private_key_openssh
  sensitive   = true
}

output "postgresql_connection_string" {
  description = "Строка подключения к БД"
  value       = "postgresql://user:password@${yandex_mdb_postgresql_cluster.main_db.host[0].fqdn}:6432/dbname"
  sensitive   = true
}