# Lucille Journal Publishing Rules

These rules apply to every agent that creates or edits an article in `content/posts/`.

1. Treat `index.md` as the canonical Chinese article.
2. In the same article directory, create or update `translation.md` with a complete natural-English translation before publishing.
3. The English front matter must contain translated `title` and `description`, plus `translation_ready: true` and `source_language: zh-CN`.
4. Preserve all claims, qualifications, headings, numbered sections, links, image paths, emphasis, lists, quotations, and horizontal rules. Do not summarize, expand, censor, fact-check, or invent details.
5. Preserve Lucille's direct personal voice. Prefer idiomatic English over literal word order.
6. If the Chinese article changes, update the English translation in the same change.
7. Set `translation_ready: true` only when the English article is complete and readable. An incomplete translation must not be exposed in the language switcher.
8. Run `hugo --cleanDestinationDir --minify` before committing or publishing.

Follow `EDITORIAL.md` for the broader editorial standard.
