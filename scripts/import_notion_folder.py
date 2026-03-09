#!/usr/bin/env python3
import argparse
import os
import re
import shutil
from datetime import datetime
from pathlib import Path

def parse_created(line: str):
    # Example: "Created: October 10, 2025 12:15 PM"
    m=re.match(r"^Created:\s+(.*)$", line.strip())
    if not m:
        return None
    s=m.group(1).strip()
    for fmt in ("%B %d, %Y %I:%M %p", "%B %d, %Y %H:%M"):
        try:
            return datetime.strptime(s, fmt)
        except Exception:
            pass
    return None

def is_asset(name: str) -> bool:
    ext = name.lower().rsplit('.',1)[-1] if '.' in name else ''
    return ext in {"png","jpg","jpeg","gif","webp","svg","pdf","mp4","mov"}

def make_slug(title: str, notion_id: str|None):
    # Prefer ASCII words if present; otherwise fall back to post-<idprefix>
    ascii_part = re.sub(r"[^a-zA-Z0-9\s-]", " ", title)
    ascii_part = re.sub(r"\s+", " ", ascii_part).strip().lower()
    if ascii_part:
        slug = re.sub(r"[^a-z0-9]+", "-", ascii_part).strip('-')
        slug = re.sub(r"-+", "-", slug)
    else:
        slug = ""
    if not slug:
        if notion_id:
            slug = f"post-{notion_id[:8]}"
        else:
            slug = "post"
    return slug

def extract_notion_id(stem: str):
    # file stem usually: "标题 <32hex>" or sometimes has spaces/extra
    m=re.search(r"\s([0-9a-f]{32})$", stem)
    return m.group(1) if m else None

def cleanup_body(lines: list[str]):
    out=[]
    for i,line in enumerate(lines):
        # strip Notion metadata lines
        if line.startswith("Created:"):
            continue
        out.append(line)
    # drop leading blank lines
    while out and out[0].strip()=="":
        out.pop(0)
    return out

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("src", help="Notion export folder containing .md")
    ap.add_argument("--dest", default="content/posts", help="Hugo section dest (default content/posts)")
    ap.add_argument("--overwrite", action="store_true")
    args=ap.parse_args()

    src=Path(args.src)
    dest=Path(args.dest)
    if not src.is_dir():
        raise SystemExit(f"src not found: {src}")
    dest.mkdir(parents=True, exist_ok=True)

    # Notion export can be nested (sub-pages). Import recursively.
    md_files=sorted([p for p in src.rglob('*.md') if p.is_file()])
    if not md_files:
        print("no markdown files")
        return

    used_slugs=set()
    imported=0

    for md in md_files:
        raw=md.read_text(encoding='utf-8', errors='ignore').splitlines(True)
        title=None
        created=None

        # title from first heading
        for line in raw[:20]:
            if line.startswith('# '):
                title=line[2:].strip()
                break
        # created line
        for line in raw[:60]:
            c=parse_created(line)
            if c:
                created=c
                break

        if not title:
            title=md.stem

        notion_id=extract_notion_id(md.stem)
        slug=make_slug(title, notion_id)
        # de-dup
        base_slug=slug
        k=2
        while slug in used_slugs or (dest/slug).exists():
            slug=f"{base_slug}-{k}"
            k+=1
        used_slugs.add(slug)

        bundle=dest/slug
        if bundle.exists():
            if not args.overwrite:
                print(f"skip existing: {bundle}")
                continue
            shutil.rmtree(bundle)
        bundle.mkdir(parents=True, exist_ok=True)

        # copy asset folder if exists (usually named exactly the title)
        asset_dir=src/title
        if asset_dir.is_dir():
            for item in asset_dir.iterdir():
                if item.is_file():
                    shutil.copy2(item, bundle/item.name)

        # remove the first heading line from content
        body=[]
        dropped_heading=False
        for line in raw:
            if (not dropped_heading) and line.startswith('# '):
                dropped_heading=True
                continue
            body.append(line)
        body=cleanup_body(body)
        text=''.join(body)

        # rewrite links to local assets if basename exists in bundle
        def repl(m):
            label=m.group(1)
            path=m.group(2)
            base=os.path.basename(path)
            if base and (bundle/base).exists() and is_asset(base):
                return f"![{label}]({base})"
            return m.group(0)
        text=re.sub(r"!\[([^\]]*)\]\(([^)]+)\)", repl, text)

        date = created or datetime.fromtimestamp(md.stat().st_mtime)
        date_str = date.strftime('%Y-%m-%dT%H:%M:%S+08:00')

        frontmatter = [
            '---\n',
            f'title: "{title.replace("\"","\\\"")}"\n',
            f'date: {date_str}\n',
            'draft: false\n',
            '---\n\n'
        ]

        (bundle/'index.md').write_text(''.join(frontmatter)+text, encoding='utf-8')
        imported += 1

    print(f"imported: {imported} posts -> {dest}")

if __name__ == '__main__':
    main()
