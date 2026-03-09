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
