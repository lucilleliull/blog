#!/usr/bin/env bash
set -euo pipefail

TITLE="${1:-}"
if [[ -z "$TITLE" ]]; then
  echo "Usage: $0 \"Title\"" >&2
  exit 1
fi

SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g')
DATE=$(date +"%Y-%m-%dT%H:%M:%S%z")
DIR="content/posts/${SLUG}"
FILE="${DIR}/index.md"

if [[ -e "$DIR" ]]; then
  echo "Exists: $DIR" >&2
  exit 1
fi

mkdir -p "$DIR"

cat > "$FILE" <<EOF2
---
title: "${TITLE}"
date: ${DATE}
draft: true
---

EOF2

echo "$FILE"
