# Как запустить

## 1. Установите переменные окружения (подставьте свои значения!)

Bash

```bash
export TF_VAR_yc_token="t1.9eu1..."
export TF_VAR_yc_cloud_id="b1g..."
export TF_VAR_yc_folder_id="b1h..."
```

Windows

```powershell
$env:TF_VAR_yc_token="t1.9eu1..."
$env:TF_VAR_yc_cloud_id="b1g..."
$env:TF_VAR_yc_folder_id="b1h..."
```

Получите IAM-токен (действует 12 часов)

> `yc iam create-token`

> Чтобы их узнать выполни `yc config list`, при этом cli клиент должен уже стоять, если не знаешь как поставить - следуй инструкции [тут](https://yandex.cloud/ru/docs/cli/quickstart)

## 2. Подготовьте tfvars

`cp terraform.tfvars.example terraform.tfvars`

Полученные ранее креды запиши сюда.

## 3. Инициализация (скачает провайдеры)

`terraform init`

Может быть проблема

![1773692061457](image/readme/1773692061457.png)

Мне помогло

```powershell
terraform providers lock -net-mirror=https://terraform-mirror.yandexcloud.net -platform=windows_amd64 yandex-cloud/yandex
```

### Для Windows (мой случай)

**Создайте файл:**
`%APPDATA%\terraform.rc`
(обычно `C:\Users\ВашПользователь\terraform.rc`)

```hcl
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

### Для Linux/macOS

Файл: `~/.terraformrc` или `/etc/terraform.d/terraform.rc`

```hcl
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

![1773693507050](image/readme/1773693507050.png)

## 4. Посмотрите, что будет создано

`terraform plan -out=tfplan`

Приложил файл `terraform plan -out=tfplan > tfplan-console.txt`

## 5. Примените (создаст ресурсы в облаке)

`terraform apply tfplan`

Ресурсы созданы

![1773694609365](image/readme/1773694609365.png)

![1773694648817](image/readme/1773694648817.png)

Кластер создавался долго...

![1773694678594](image/readme/1773694678594.png)

## 6. Подключитесь к ВМ (ключ сохранится в generated_ssh_key.pem)

```powershell
chmod 600 generated_ssh_key.pem
ssh -i generated_ssh_key.pem ubuntu@<IP-из-output>
```

## Удалить все созданные ресурсы

`terraform destroy`

![1773694942919](image/readme/1773694942919.png)

Запрос подтверждения

![1773694974969](image/readme/1773694974969.png)

Final

![1773695001663](image/readme/1773695001663.png)

![1773695048507](image/readme/1773695048507.png)

## Очистить локальные артефакты

`rm -rf .terraform* terraform.tfstate* tfplan generated_ssh_key.pem`
