#!/usr/bin/env bash
set -euo pipefail

git status --porcelain

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
