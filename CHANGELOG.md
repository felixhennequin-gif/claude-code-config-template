# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `SECURITY.md` — vulnerability reporting policy
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1
- `CHANGELOG.md` — this file
- `.github/ISSUE_TEMPLATE/{bug_report,feature_request,new_skill}.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/FUNDING.yml`
- `.github/workflows/lint.yml` — CI: `settings.json` JSON validation, `shellcheck` on hooks, frontmatter field check on skills / agents / rules, and a baseline secret scan (IPv4, secret-looking env assignments, PEM headers)
- `examples/express-api.CLAUDE.md` — generic Express 5 + Prisma REST API template
- `examples/nextjs-fullstack.CLAUDE.md` — generic Next.js 15 + Prisma + Tailwind template
- `examples/README.md` — index and contribution notes for examples
- `template/CLAUDE.local.md.example` — tracked personal-override template that clones actually receive
- Root `CLAUDE.md` describing this template repo itself (separate from the downstream-facing template copied into user projects)
- README "Contributing" and "Community" section

### Changed

- `reviewer` agent no longer asks for per-controller `try/catch` — aligned with the `express-api` skill, which forbids it under Express 5
- `security-auditor` agent no longer hardcodes PM2 — it now follows the process-manager choice from `CLAUDE.md`
- Downstream-facing `CLAUDE.md` template moved from repo root to `template/CLAUDE.md` so the root `CLAUDE.md` can describe the template repo itself
- `CLAUDE.local.md.example` moved to `template/CLAUDE.local.md.example` to sit alongside the downstream template
- README structure tree now lists `template/`, `examples/`, `CHANGELOG.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, and `.github/`
- README structure tree no longer lists `.claude/settings.local.json` — it's gitignored and never ships with the template
- Install snippet now copies `template/CLAUDE.local.md.example` (the previous instructions copied a gitignored file that was absent from fresh clones)
- `CONTRIBUTING.md` example length budget aligned with `examples/README.md` (~80 lines, matching the downstream `CLAUDE.md` budget)
- `CODE_OF_CONDUCT.md` enforcement contact filled in (was `[INSERT CONTACT METHOD]`)

## [0.1.0] — 2026-04-13

Initial release of the template.

### Added

- `CLAUDE.md` — project context file (stack, structure, commands, conventions, git workflow)
- `CLAUDE.local.md` — personal overrides template (gitignored)
- `.claude/settings.json` — deterministic hooks and permissions
- `.claude/agents/reviewer.md` — automated code review subagent
- `.claude/agents/security-auditor.md` — targeted security audit subagent
- `.claude/commands/deploy.md` — `/deploy` slash command (server-agnostic)
- `.claude/commands/audit.md` — `/audit` slash command (full quality audit)
- `.claude/commands/test.md` — `/test` slash command (tests + coverage)
- `.claude/skills/prisma-patterns/SKILL.md` — Prisma 7 conventions
- `.claude/skills/express-api/SKILL.md` — Express 5 patterns
- `.claude/skills/react-frontend/SKILL.md` — React 19 + Tailwind v4 patterns
- `.claude/hooks/lint-on-edit.sh` — auto-lint hook (reads payload from stdin)
- `.claude/rules/test-files.md` — test file conventions
- `CONTRIBUTING.md` — contribution guide
- `RESEARCH.md` — raw research data from ~55 open-source repos
- `LICENSE` — MIT

### Fixed

- Hooks now parse their payload from stdin instead of a missing env var
- `/deploy` command no longer hardcodes a specific server

[Unreleased]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/felixhennequin-gif/claude-code-config-template/releases/tag/v0.1.0
