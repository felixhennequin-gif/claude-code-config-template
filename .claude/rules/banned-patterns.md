<!--
Path-scoped project rule — loaded by Claude Code when editing matching files.
Mechanism: https://code.claude.com/docs/en/memory#path-specific-rules
The correct frontmatter field is `paths:` (Claude Code), not `globs:` (Cursor).
-->
---
name: banned-patterns
description: Anti-patterns that should never appear in source code. Loaded when editing JS/TS or Python files. Apply only the section matching the file you're editing.
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
  - "**/*.py"
---

# Banned patterns

Three sections: **Universal** applies everywhere; **JavaScript / TypeScript** and **Python** apply only to their respective files. When editing, scan the section matching the file extension — don't apply JS rules to Python code or vice versa.

## Universal (all languages)

- Never commit `.env` files, API keys, tokens, or secrets to git
- Never use ad-hoc stdout (`console.log`, `print()`, `fmt.Println`) for production logging — use a structured logger
- Never catch exceptions silently — at minimum, log them
- Never hardcode URLs, ports, or hostnames — use environment variables or config
- Never use `eval()` or equivalent dynamic-code-execution primitives

## JavaScript / TypeScript

- Never use `var` — use `const` by default, `let` when reassignment is needed
- Never use `==` — always `===`
- Never use `any` — use `unknown` if the type is genuinely unknown, then narrow
- Never use `fs.readFileSync` / `fs.writeFileSync` in server code — use async versions
- Never use `new Date()` for time comparisons across timezones — use a library (date-fns, dayjs)
- Never leave empty `catch {}` blocks — at minimum, log the error

## Python

- Never use mutable default arguments (`def fn(items=[])`) — use `None` and initialize inside
- Never use `import *` — always explicit imports
- Never use `os.system()` — use `subprocess.run()` with `shell=False`
- Never use bare `except:` — always catch specific exceptions
- Never use `exec()` — there is no safe use case in application code
