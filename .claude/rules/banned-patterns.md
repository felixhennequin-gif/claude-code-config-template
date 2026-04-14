<!--
Path-scoped project rule — loaded by Claude Code when editing matching files.
Mechanism: https://code.claude.com/docs/en/memory#path-specific-rules
The correct frontmatter field is `paths:` (Claude Code), not `globs:` (Cursor).
-->
---
name: banned-patterns
description: Patterns that should never appear in JS/TS code — Claude must flag or refuse these. Loaded when editing JavaScript or TypeScript source.
paths:
  - "**/*.{ts,tsx,js,jsx,mjs,cjs}"
---

## Universal (all languages)

- Never commit `.env` files, API keys, tokens, or secrets to git
- Never use `console.log` for production logging — use a structured logger
- Never catch exceptions silently (`catch {}`) — at minimum, log them
- Never hardcode URLs, ports, or hostnames — use environment variables or config
- Never use `any` type in TypeScript — use `unknown` if the type is genuinely unknown
- Never use `eval()` in any language

## JavaScript / TypeScript

- Never use `var` — use `const` by default, `let` when reassignment is needed
- Never use `==` — always `===`
- Never use `fs.readFileSync` / `fs.writeFileSync` in server code — use async versions
- Never use `new Date()` for time comparisons across timezones — use a library (date-fns, dayjs)
