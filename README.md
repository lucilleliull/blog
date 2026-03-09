# blog

Hugo + Cloudflare Pages.

> Content source: 本地文件夹「lucille博客文章」（Notion 导出的 Markdown）。

## 本地预览

```bash
hugo server -D
```

## 新建文章（两种工作流）

### 工作流 A：命令行

```bash
./scripts/new-post.sh "标题"
./scripts/publish.sh
```

### 工作流 B：跟川哥聊天

在对话里说：

- “川哥，发一篇文章：标题=...；栏目=posts；内容=...”
- 或 “川哥，把 Obsidian 里的某篇笔记发布为文章：文件=...；标题=...”

川哥会在仓库里生成/更新 Markdown，然后 commit + push。

## 部署

Cloudflare Pages 连接 GitHub 仓库，构建命令：

- Build command: `hugo --minify`
- Output directory: `public`
- Environment: `HUGO_VERSION=0.157.0`

