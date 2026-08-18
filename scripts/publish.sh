#!/usr/bin/env bash
set -euo pipefail

git status --porcelain

echo "\nPreparing English translations..."
CHANGED_ARTICLES=$(git status --porcelain --untracked-files=all content/posts | sed -n 's/^...//p' | grep '/index\.md$' || true)
if [[ -n "$CHANGED_ARTICLES" ]]; then
  while IFS= read -r SOURCE; do
    [[ -n "$SOURCE" && -f "$SOURCE" ]] || continue
    TRANSLATION="$(dirname "$SOURCE")/translation.md"
    if [[ -n "$(git status --porcelain -- "$TRANSLATION")" ]]; then
      echo "Using the English translation already prepared for $SOURCE"
    else
      scripts/translate-post.sh "$SOURCE"
    fi
  done <<< "$CHANGED_ARTICLES"
else
  echo "No new or edited Chinese articles."
fi

echo "\nRunning hugo build..."
hugo --minify >/dev/null

echo "\nCommit + push..."
git add -A

if git diff --cached --quiet; then
  echo "Nothing new to commit; publishing the current commit."
else
  git commit -m "Publish"
fi

git push origin HEAD:main

echo "\nDeploying to Cloudflare Pages..."
COMMIT_SHA=$(git rev-parse HEAD)
npx wrangler@latest pages deploy public \
  --project-name lucille-blog \
  --branch main \
  --commit-hash "$COMMIT_SHA" \
  --commit-dirty=false

echo "\nPublished: https://lucille-blog.pages.dev/"
