#!/usr/bin/env python3
"""Check internal markdown links in tracked .md files.

Walks every tracked *.md file, parses [text](target) links, and verifies
that relative targets resolve to a file on disk. External URLs (http/https,
mailto, tel, ftp, data) and template placeholders (`<...>`) are skipped.
Exits non-zero if any broken internal link is found.
"""
import os
import re
import subprocess
import sys

LINK_RE = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
EXTERNAL_RE = re.compile(r'^(https?|mailto|tel|ftp|data):')


def tracked_markdown_files():
    out = subprocess.check_output(
        ['git', 'ls-files', '*.md'], text=True
    )
    return [line for line in out.splitlines() if line]


CODE_SPAN_RE = re.compile(r'`[^`\n]*`')
FENCED_RE = re.compile(r'```.*?```', re.DOTALL)


def strip_code(src):
    src = FENCED_RE.sub('', src)
    src = CODE_SPAN_RE.sub('', src)
    return src


def check_file(md):
    with open(md, encoding='utf-8') as fh:
        src = strip_code(fh.read())
    base = os.path.dirname(md)
    bad = 0
    for m in LINK_RE.finditer(src):
        target = m.group(2).strip()
        target = target.split('#', 1)[0].split('?', 1)[0]
        if not target:
            continue
        if EXTERNAL_RE.match(target):
            continue
        if target.startswith('<') and target.endswith('>'):
            continue
        resolved = os.path.normpath(os.path.join(base, target))
        if not os.path.exists(resolved):
            print(
                f"::error file={md}::broken internal link: "
                f"'{target}' (resolved to '{resolved}')"
            )
            bad += 1
    return bad


def main():
    fail = 0
    for md in tracked_markdown_files():
        fail += check_file(md)
    return 1 if fail else 0


if __name__ == '__main__':
    sys.exit(main())
