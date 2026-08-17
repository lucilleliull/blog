# LUCILLE

一份用 Hugo、Markdown、GitHub 和 Cloudflare Pages 维护的个人长期出版物。

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

GitHub 保存文章和版本历史；当前 Cloudflare Pages 项目采用 Direct Upload。`./scripts/publish.sh` 会依次完成：

1. `hugo --minify` 生产构建。
2. commit 并 push 到 GitHub。
3. 通过 Wrangler 将 `public/` 发布到 `lucille-blog` Pages 项目。

第一次发布时，Wrangler 可能会要求在浏览器完成一次 Cloudflare 登录。手动发布命令：

```bash
hugo --minify
npx wrangler@latest pages deploy public --project-name lucille-blog --branch main
```

## 内容目录

- `content/posts/<slug>/index.md`：正式文章；同目录可以放文章图片或 PDF。
- `content/projects/<slug>/index.md`：项目；同目录放代表图和过程图。
- `content/about/_index.md`：关于页文案。
- `content-template.md`：最简文章模板。
- `EDITORIAL.md`：文章准入与编辑原则。

新增项目：

```bash
hugo new projects/project-slug/index.md
```

图片默认与正文同宽。需要宽图时，在 Markdown 图片后加入 Hugo 属性：

```markdown
![说明](image.jpg){class="wide"}
![说明](image.jpg){class="full"}
```

## 回滚

发布前先运行 `git log --oneline` 找到要恢复的版本，再用 `git revert <commit>` 创建一个可追踪的回滚提交并 push。不要改写已经发布的 Git 历史。
