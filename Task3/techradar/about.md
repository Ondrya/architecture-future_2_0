# How to use the Technology Radar

### Introduction

Edit this file to your needs to provide an introduction to the technology radar. Explain the purpose
of the radar and how it is created. This is a good place to explain the quadrants and rings, too.

### Contributing to the AOE Technology Radar

Contributions and source code of the AOE Tech Radar are on
GitHub: [AOE Tech Radar on GitHub](https://github.com/AOEpeople/aoe_technology_radar)

## Шаблон записи

```markdown
---
title: "Data Mesh"
ring: "adopt"
quadrant: "methods-and-patterns"
tags: [new]
---

Data Mesh

![stub](/images/logo.svg)

[ADR](/adr/datamesh.md)

```

* title — название технологии;
* ring — кольцо (идентификатор из `<span class="code-inline__content">config.json</span>`);
* quadrant — квадрант (идентификатор из `<span class="code-inline__content">config.json</span>`);
* tags — произвольно для быстрого доступа.

Можно вставить изображение, которое предварительно положим в images директорию в public
