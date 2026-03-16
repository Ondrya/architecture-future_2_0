# variables.tf

# 🔑 Обязательные данные для доступа к Yandex Cloud
variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true  # не показывать в логах
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
}

# 🌐 Сетевые настройки
variable "subnets" {
  type = map(object({
    zone = string
    cidr = string
  }))
  description = "Подсети для ресурсов"
  default = {
    "web-subnet" = {
      zone = "ru-central1-a"
      cidr = "192.168.10.0/24"
    }
    "db-subnet" = {
      zone = "ru-central1-a"
      cidr = "192.168.20.0/24"
    }
    "db-subnet-b" = {
      zone = "ru-central1-b"
      cidr = "192.168.21.0/24"
    }
  }
}

# 💻 Параметры виртуальных машин
variable "vm_instances" {
  type = map(object({
    zone     = string
    subnet   = string
    cores    = number
    memory   = number
    disk_size = number
  }))
  default = {
    "web-vm" = {
      zone      = "ru-central1-a"
      subnet    = "web-subnet"
      cores     = 2
      memory    = 2
      disk_size = 15
    }
  }
}

# 🪣 Object Storage
variable "bucket_name" {
  type    = string
  default = "terraform-state-bucket"
}

# 🧹 Опция авто-очистки при ошибках
variable "enable_auto_cleanup" {
  description = "Автоматически удалять ресурсы при ошибках"
  type        = bool
  default     = true
}