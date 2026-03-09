---
title: "用 OpenClaw 从零搭建 Hugo 博客：Cloudflare Pages + GitHub（lucille 版）"
date: 2026-03-09T22:46:00+08:00
draft: false
---

这篇文章记录我和「川哥」一起把笔记发到公网的全过程。

目标很简单：
- 写作入口：本地一个文件夹（Markdown）+ 平时跟川哥聊天
- 构建器：Hugo
- 仓库：GitHub
- 托管：Cloudflare Pages（免费 `*.pages.dev`）
- 风格：极简，正文优先

最后产物：
- 网站：`https://blog-b3g.pages.dev`
- 源码仓库：`https://github.com/lucilleliull/blog`

---

## 0. 这套东西的本质

一条流水线：

1) 我把内容写成 Markdown
2) Hugo 把 Markdown 变成静态 HTML
3) GitHub 存源码
4) Cloudflare Pages 拉 GitHub → 跑 `hugo --minify` → 把 `public/` 放到 CDN

我只需要维护：
- 一个仓库
- 一个内容文件夹
- 一个“同步发布”的指令

---

## 1. 创建 Hugo 站点（本地）

目录（例）：

```bash
/Users/lucille/.openclaw/workspace/blog/blog
```

初始化：

```bash
hugo new site blog
```

关键文件：
- `hugo.toml`：站点配置
- `content/posts/`：文章
- `themes/`：主题

---

## 2. 选一个极简主题（我用 PaperMod）

我选 PaperMod 的原因：
- 首页干净
- 文章阅读体验直
- 搜索/归档这些“信息架子”能加上

注意：Cloudflare Pages 的构建环境对 git submodule 有时不友好。
所以最终做法是：把主题 **vendor 到仓库**（themes 文件夹直接提交），避免“构建时拉不到主题”。

---

## 3. 站点配置（hugo.toml）

我保留了几条核心配置：
- 标题：`刘露西西 / 人生指南针`
- 输出：HTML + RSS + JSON（用于搜索）
- 菜单：文章 / 标签 / 搜索 / 归档 / 关于

一个坑：Cloudflare 默认 Hugo 版本可能比较旧，配置键的兼容性会踩雷。

我遇到的错误：

> `paginate` 在某些 Hugo 版本里被移除

修法：
- 把 `paginate = 20`
- 改成

```toml
[pagination]
  pagerSize = 20
```

---

## 4. GitHub 建仓库 + push

仓库：

- `https://github.com/lucilleliull/blog`

核心动作：

```bash
git init
git remote add origin https://github.com/lucilleliull/blog.git
git branch -M main
git push -u origin main
```

如果 HTTPS push 需要授权，推荐用 GitHub CLI 做 device login（不需要手敲 token）。

---

## 5. Cloudflare Pages 连接 GitHub

Cloudflare 的关键是：一定要建 **Pages 项目**，不要误进 Workers 的向导。

Pages 的构建配置：
- Build command：`hugo --minify`
- Build output directory：`public`

建议加环境变量（锁 Hugo 版本）：
- `HUGO_VERSION=0.157.0`

完成后 Cloudflare 会给一个免费域名：
- `https://blog-b3g.pages.dev`

---

## 6. 404 的定位方式（我怎么确认问题在 CF 侧）

当我看到浏览器 404，我先做两件事：

1) 直接 curl 看服务器返回

```bash
curl -I https://blog-b3g.pages.dev/
```

2) 去 CF Deployments 看 build log

结论：
- 站点 404 ≠ 文章没写好
- 更多时候是：构建失败 / 没产物 / 输出目录错

这次就是 Hugo 配置兼容性导致构建失败，修完 `pagination` 就恢复。

---

## 7. 我的发文工作流（两种入口）

### 工作流 A：命令行

新增文章：

```bash
./scripts/new-post.sh "标题"
```

发布：

```bash
./scripts/publish.sh
```

本质：生成 Markdown → commit → push → Cloudflare 自动部署。

### 工作流 B：跟川哥聊天

我用一句话描述需求：

- “川哥，发文：标题=…；内容=…”
- “川哥，同步发布 lucille博客文章”

川哥做剩下的事：
- 把文件夹里的 md 变成 `content/posts/<slug>/index.md`
- 写 frontmatter（title/date/draft）
- commit + push

我只管内容。

---

## 8. 从文件夹批量发布（lucille博客文章）

我的内容源是一个本地文件夹：

- `/Users/lucille/Desktop/PARA/01 Project/lucille博客文章`

规则：
- 读取 `# 标题`
- 读取 `Created:` 当作文章时间（没有就用文件修改时间）
- 写成 Hugo bundle：`content/posts/<slug>/index.md`

这比“手动复制到后台”更像一个工程：
- 内容=文件
- 发布=一次 commit
- 历史=git log

---

## 9. 你也可以复刻（最短 checklist）

1) Hugo 初始化站点
2) 选主题（建议直接 vendor）
3) push 到 GitHub
4) Cloudflare Pages 连接 repo
5) Build command = `hugo --minify`，output = `public`
6) build log 报错就从配置键开始查

---

如果你想做同款：
- 你只需要给我：GitHub repo + Cloudflare Pages 项目
- 然后把你的 Markdown 丢进一个文件夹
- 剩下交给流水线
