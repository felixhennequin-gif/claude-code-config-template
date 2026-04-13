# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/felixhennequin-gif/ai-config-template/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/felixhennequin-gif/ai-config-template/releases/tag/v0.1.0
