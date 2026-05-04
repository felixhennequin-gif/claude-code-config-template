# Validation checklist & smoke test results

> Results below are from the template author's own project. Non-Node stacks are untested. If you validate on a different stack, please contribute your results via PR.

This file tracks smoke-test runs of the template on concrete projects, to surface where the conventions, hooks, and skills produce different Claude Code behavior compared to a bare setup.

## Test methodology

For each project:
1. Run `npx create-claude-code-config` to install the template
2. Let Claude Code explore the architecture and fill CLAUDE.md
3. Observe hook behavior, convention adherence, and CLI correctness

---

## CLI validation — Neighborhood Web App (Node.js / Express 5 / Prisma 7 / React 19)

**Date**: April 2026
**Stack**: Node.js ESM, TypeScript, Express 5, Prisma 7, PostgreSQL, Socket.io, React 19, Vite 8, Tailwind v4, Zod 4
**Install method**: `npx create-claude-code-config@0.8.0`

### Install result

- 22 files tracked in manifest
- npm/npx permissions auto-injected into `.claude/settings.json`
- `.gitignore` updated automatically (CLAUDE.local.md, settings.local.json, manifest)
- Time to install: ~30 seconds including npx package download on first run

### Update result (`--update` immediately after install)

- 0 updated, 1 skipped (settings.json — excluded by design), 20 already up to date
- No false positives, no data loss
- Correct behavior confirmed

### Claude Code architecture exploration

Claude Code was asked to explore the project and fill CLAUDE.md from scratch.
It correctly identified:

- ESM `.js` extension requirement for TypeScript imports in backend
- Prisma client emitted to `backend/generated/prisma` (not default `node_modules/@prisma/client`)
- Zod v4 exposes `.issues`, not `.errors` — error formatters must use `.issues[0].message`
- Express 5 auto-propagates async handler errors — no need for try/catch wrappers in controllers

These are non-trivial, version-specific gotchas that Claude would not reliably catch
without the structured exploration prompt. The resulting CLAUDE.md was 77 lines,
under the 80-line limit.

### Convention adherence

- The branch guard hook (`settings.json` PreToolUse) blocked direct edits on `main`
- Claude Code opened a PR via `gh pr create` instead of pushing directly
- CLAUDE.md convention ("main = production, tout passe par PR") was respected without manual intervention

---

## Observations from this run

- The CLI install is fast (~30s) and requires zero manual configuration for Node stacks
- The `--update` manifest detection works correctly: SHA-256 comparison catches untouched files, customized files are left intact
- `settings.json` exclusion from `--update` is the right call — injected permissions vary per project
- The architecture exploration prompt surfaced non-trivial, version-specific gotchas
- The branch guard hook enforced conventions without requiring the user to remember them

## What to watch

- Non-Node stacks are untested — the core skills (coding-principles, debugging, error-handling) are stack-agnostic but the stack skills need real-world validation
- CLAUDE.local.md.example → CLAUDE.local.md flow not yet tested (no user filled in personal overrides during this test)
