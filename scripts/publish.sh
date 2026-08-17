#!/usr/bin/env bash
set -euo pipefail

git status --porcelain

echo "\nRunning hugo build..."
hugo --minify >/dev/null

echo "\nCommit + push..."
git add -A

git commit -m "Publish" || {
  echo "Nothing to commit.";
  exit 0;
}

git push

echo "\nDeploying to Cloudflare Pages..."
COMMIT_SHA=$(git rev-parse HEAD)
npx wrangler@latest pages deploy public \
  --project-name lucille-blog \
  --branch main \
  --commit-hash "$COMMIT_SHA" \
  --commit-dirty=false

echo "\nPublished: https://lucille-blog.pages.dev/"
