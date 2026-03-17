---
title: "Terraform"
ring: "adopt"
quadrant: "tools"
tags: [new]
---

# Terraform (Infrastructure as Code)

![stub](/images/terraform.svg)

[ADR](/adr/terraform.md)

**Бизнес-сценарии:**
- Быстрое развёртывание сред для новых доменов
- Воспроизводимость инфраструктуры
- Снижение ручных ошибок при деплое

**Обоснование:**
Декларативное управление облачными ресурсами. Позволяет версионировать инфраструктуру, упрощает disaster recovery.

**Риски:**
- Требует обучения команды
- Необходимость управления state-файлами

**Владелец:** Platform Engineering