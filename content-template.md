---
title: ""
date: 2026-01-01T09:00:00+08:00
description: ""
tags: []
draft: true
---

正文从这里开始。

<!-- 图片放在与 index.md 同一目录：![替代文字](image.jpg) -->

## 双语发布

中文正文保存在 `index.md`。发布脚本会为新增或修改过的中文文章自动生成同目录下的 `translation.md`，文章页随后显示“中文 / English”切换。

英文文件格式：

```yaml
---
title: "English title"
description: "English description"
translation_ready: true
source_language: zh-CN
---
```

不要把中英文正文混写在 `index.md` 中；图片、链接、标题层级和分隔线必须在两种语言中保持对应。
