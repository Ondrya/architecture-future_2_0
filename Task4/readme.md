# Как запустить

## 1. Установите переменные окружения (подставьте свои значения!)

export TF_VAR_yc_token="t1.9eu1..."
export TF_VAR_yc_cloud_id="b1g..."
export TF_VAR_yc_folder_id="b1h..."

## 2. Подготовьте tfvars

cp terraform.tfvars.example terraform.tfvars

## 3. Инициализация (скачает провайдеры)

terraform init

## 4. Посмотрите, что будет создано

terraform plan -out=tfplan

## 5. Примените (создаст ресурсы в облаке)

terraform apply tfplan

## 6. Подключитесь к ВМ (ключ сохранится в generated_ssh_key.pem)

chmod 600 generated_ssh_key.pem
ssh -i generated_ssh_key.pem ubuntu@<IP-из-output>

## Удалить все созданные ресурсы

terraform destroy

## Очистить локальные артефакты

rm -rf .terraform* terraform.tfstate* tfplan generated_ssh_key.pem
