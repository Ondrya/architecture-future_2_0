# provider.tf
terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.120"  # фиксируем мажорную версию
    }
    tls = {
      source  = "hashicorp/tls" # Провайдер tls нужен для генерации SSH-ключей
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"  # минимальная версия Terraform
}

provider "yandex" {
  token     = var.yc_token      # берём из переменных
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"   # зона по умолчанию
}