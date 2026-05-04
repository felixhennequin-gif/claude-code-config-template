#!/usr/bin/env python3
"""Warn (never fail) when stack skills go stale.

Scans `.claude/skills/stacks/*/SKILL.md` for a `last-verified: YYYY-MM-DD`
field in the frontmatter. Emits GitHub Actions warning annotations when a
skill is missing the field or has not been verified in more than 90 days.

Exit code is always 0 — this is an advisory check, not a gate. The policy
("per major version OR every 90 days, whichever comes first") lives in
CONTRIBUTING.md.
"""

from __future__ import annotations

import datetime as dt
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
STACKS = ROOT / ".claude" / "skills" / "stacks"
THRESHOLD_DAYS = 90
DATE_RE = re.compile(r"^last-verified:\s*(\d{4}-\d{2}-\d{2})\s*$", re.MULTILINE)


def frontmatter(text: str) -> str:
    if not text.startswith("---\n"):
        return ""
    end = text.find("\n---", 4)
    return text[4:end] if end != -1 else ""


def main() -> int:
    today = dt.date.today()
    skills = sorted(STACKS.glob("*/SKILL.md"))
    if not skills:
        print("no stack skills found", file=sys.stderr)
        return 0

    warnings = 0
    for path in skills:
        rel = path.relative_to(ROOT)
        fm = frontmatter(path.read_text(encoding="utf-8"))
        match = DATE_RE.search(fm)
        if not match:
            print(f"::warning file={rel}::missing 'last-verified: YYYY-MM-DD' in frontmatter")
            warnings += 1
            continue
        try:
            verified = dt.date.fromisoformat(match.group(1))
        except ValueError:
            print(f"::warning file={rel}::invalid last-verified date: {match.group(1)}")
            warnings += 1
            continue
        age = (today - verified).days
        if age > THRESHOLD_DAYS:
            print(
                f"::warning file={rel}::last-verified is {age} days old "
                f"(> {THRESHOLD_DAYS}) — re-check this skill against upstream docs"
            )
            warnings += 1

    if warnings == 0:
        print(f"skill freshness OK ({len(skills)} stack skills, all ≤ {THRESHOLD_DAYS} days)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
