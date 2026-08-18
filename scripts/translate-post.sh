#!/usr/bin/env bash
set -euo pipefail

SOURCE="${1:-}"
if [[ -z "$SOURCE" || ! -f "$SOURCE" ]]; then
  echo "Usage: $0 content/posts/<slug>/index.md" >&2
  exit 1
fi

HERMES_BIN="${HERMES_BIN:-$(command -v hermes || true)}"
if [[ -z "$HERMES_BIN" && -x "/Users/lucille/.local/bin/hermes" ]]; then
  HERMES_BIN="/Users/lucille/.local/bin/hermes"
fi
if [[ -z "$HERMES_BIN" ]]; then
  echo "Hermes is required to create the English translation." >&2
  exit 1
fi

TARGET="$(dirname "$SOURCE")/translation.md"
TEMP_FILE="$(mktemp "${TMPDIR:-/tmp}/lucille-translation.XXXXXX")"
trap 'rm -f "$TEMP_FILE"' EXIT

SOURCE_CONTENT="$(<"$SOURCE")"
PROMPT="Translate the following Chinese journal article into polished, natural English for Lucille's personal website.

Return ONLY the complete contents of translation.md. Do not use a Markdown code fence and do not add commentary.

Required front matter:
---
title: \"Natural English title\"
description: \"Natural English description\"
translation_ready: true
source_language: zh-CN
---

Translation rules:
- Preserve every claim, qualification, numbered section, heading, list, link, image path, emphasis, and horizontal rule.
- Preserve Lucille's direct, personal voice. Prefer idiomatic English over literal word order.
- Do not summarize, censor, expand, fact-check, or invent details.
- Translate visible Chinese text, but keep proper nouns and established product names accurate.
- Do not copy the Chinese front matter fields other than their translated title and description.

SOURCE ARTICLE:
$SOURCE_CONTENT"

"$HERMES_BIN" --ignore-rules --oneshot "$PROMPT" > "$TEMP_FILE"

if [[ "$(sed -n '1p' "$TEMP_FILE")" != "---" ]]; then
  echo "Translation output is missing YAML front matter." >&2
  exit 1
fi
if ! grep -q '^translation_ready: true$' "$TEMP_FILE"; then
  echo "Translation output is not marked ready." >&2
  exit 1
fi
if [[ "$(wc -c < "$TEMP_FILE")" -lt 200 ]]; then
  echo "Translation output is unexpectedly short." >&2
  exit 1
fi

mv "$TEMP_FILE" "$TARGET"
trap - EXIT
echo "English translation ready: $TARGET"
