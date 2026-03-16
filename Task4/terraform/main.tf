###########################################################
###########        Генерация SSH-ключа           ##########
###########################################################

# Генерация пары RSA-ключей для доступа к ВМ
resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Сохранение приватного ключа в файл (доступен только вам)
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.vm_ssh_key.private_key_openssh
  filename        = "${path.module}/generated_ssh_key.pem"
  file_permission = "0600"  # chmod 600
}

###########################################################
###########        Сеть и безопасность           ##########
###########################################################

# VPC сеть
resource "yandex_vpc_network" "main" {
  name        = "main-network"
  description = "Основная сеть для инфраструктуры"
}

# Подсети (создаём несколько через for_each)
resource "yandex_vpc_subnet" "subnets" {
  for_each = var.subnets

  name           = each.key
  zone           = each.value.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [each.value.cidr]
}

# Группа безопасности (firewall)
resource "yandex_vpc_security_group" "main" {
  name        = "main-security-group"
  description = "Основная группа безопасности"
  network_id  = yandex_vpc_network.main.id

  # Разрешаем входящий SSH
  ingress {
    protocol       = "TCP"
    description    = "SSH access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  # Разрешаем HTTP/HTTPS
  ingress {
    protocol       = "TCP"
    description    = "HTTP access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }
  ingress {
    protocol       = "TCP"
    description    = "HTTPS access"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Исходящий трафик — весь разрешён
  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

###########################################################
###########    Сервисный аккаунт и права     ##############
###########################################################

# Сервисный аккаунт для управления ресурсами
resource "yandex_iam_service_account" "main" {
  name        = "terraform-sa"
  description = "Service account for Terraform managed resources"
}

# Даём права редактора в каталоге
resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.yc_folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.main.id}"
}

# Права на Object Storage
resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.yc_folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.main.id}"
}

# Статические ключи доступа для бакета
resource "yandex_iam_service_account_static_access_key" "sa_static_key" {
  service_account_id = yandex_iam_service_account.main.id
  description        = "Static access key for object storage"
}

###########################################################
########### PostgreSQL кластер (управляемая БД)  ##########
###########################################################

# Управляемый PostgreSQL
resource "yandex_mdb_postgresql_cluster" "main_db" {
  name        = "main-postgresql-cluster"
  environment = "PRODUCTION"  # или "PRESTABLE" для тестов
  network_id  = yandex_vpc_network.main.id

  config {
    version = 15  # версия PostgreSQL
    resources {
      resource_preset_id = "s2.micro"  # 2 vCPU, 4GB RAM
      disk_type_id       = "network-ssd"
      disk_size          = 10  # GB
    }
  }

  # Хосты в разных зонах для отказоустойчивости
  host {
    zone       = "ru-central1-a"
    subnet_id  = yandex_vpc_subnet.subnets["db-subnet"].id
  }
  host {
    zone       = "ru-central1-b"
    subnet_id  = yandex_vpc_subnet.subnets["db-subnet-b"].id
  }

  depends_on = [
    yandex_vpc_subnet.subnets["db-subnet"],
    yandex_vpc_subnet.subnets["db-subnet-b"],
    yandex_vpc_security_group.main
  ]
}

###########################################################
####### Object Storage (S3-совместимое хранилище)  ########
###########################################################

# Случайный суффикс для уникальности имени бакета
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Бакет в Object Storage
resource "yandex_storage_bucket" "main" {
  bucket      = "${var.bucket_name}-${random_id.bucket_suffix.hex}"
  access_key  = yandex_iam_service_account_static_access_key.sa_static_key.access_key
  secret_key  = yandex_iam_service_account_static_access_key.sa_static_key.secret_key

  depends_on = [yandex_iam_service_account_static_access_key.sa_static_key]
}

###########################################################
##################### Виртуальные машины  #################
###########################################################

# Образ Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# ВМ (создаём через for_each из переменной)
resource "yandex_compute_instance" "vms" {
  for_each = var.vm_instances

  name        = each.key
  zone        = each.value.zone
  platform_id = "standard-v3"  # современная платформа

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = each.value.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnets[each.value.subnet].id
    nat       = true  # публичный IP
  }

  # Передаём публичный SSH-ключ для входа
  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.vm_ssh_key.public_key_openssh}"
  }

  depends_on = [
    yandex_vpc_subnet.subnets,
    yandex_vpc_security_group.main
  ]
}

