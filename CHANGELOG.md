# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `.claude/skills/coding-principles/SKILL.md` — stack-agnostic behavioral skill condensing Andrej Karpathy's four coding principles (think before coding, simplicity first, surgical changes, goal-driven execution) into actionable rules with concrete "senior engineer" tests. Adapted from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills). Triggers on every coding task and cross-references the stack-specific skills.

## [0.1.0] — 2026-04-13

Initial public release of the template.

### Added

#### Project context

- Root `CLAUDE.md` — describes this template repo itself (loaded when Claude Code works *on* the template)
- `template/CLAUDE.md` — downstream-facing project context file users copy into their own projects (stack, structure, commands, conventions, git workflow, gotchas) — deliberately under ~80 lines
- `template/CLAUDE.local.md.example` — tracked personal-override template that clones actually receive; users copy it to the gitignored `CLAUDE.local.md`

#### `.claude/` runtime configuration

- `.claude/settings.json` — `PreToolUse` guard blocking edits on `main`, `PostToolUse` auto-lint hook, and a scoped `permissions.allow` / `permissions.deny` list
- `.claude/hooks/lint-on-edit.sh` — parses `tool_input.file_path` from stdin (with a `jq` → `node` fallback) and runs `npx --no-install eslint --fix` on JS/TS files; non-blocking (always exits 0)
- `.claude/agents/reviewer.md` — code review subagent (`tools: Read, Grep, Glob`, `model: sonnet`)
- `.claude/agents/security-auditor.md` — security audit subagent scoped to `Read, Grep, Glob, Bash(npm audit:*)`
- `.claude/commands/deploy.md` — `/deploy` slash command (server-agnostic deployment workflow)
- `.claude/commands/audit.md` — `/audit` slash command (full quality audit)
- `.claude/commands/test.md` — `/test` slash command (tests + coverage)
- `.claude/skills/prisma-patterns/SKILL.md` — Prisma 7 conventions
- `.claude/skills/express-api/SKILL.md` — Express 5 patterns
- `.claude/skills/react-frontend/SKILL.md` — React 19 + Vite + Tailwind v4 patterns
- `.claude/rules/test-files.md` — test file conventions scoped via `globs:` to `**/*.test.*`, `**/*.spec.*`, `**/tests/**`, `**/__tests__/**`

#### Examples

- `examples/README.md` — index, usage instructions, and contribution notes
- `examples/express-api.CLAUDE.md` — Express 5 + Prisma 7 + PostgreSQL REST API template
- `examples/nextjs-fullstack.CLAUDE.md` — Next.js 15 App Router + Prisma 7 + Tailwind v4 template

#### Community infrastructure

- `README.md` — landing page with install snippet, principles, and contributing section
- `CONTRIBUTING.md` — contribution guide with quality bar for skills, agents, commands, and examples
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1
- `SECURITY.md` — vulnerability reporting policy
- `CHANGELOG.md` — this file
- `LICENSE` — MIT
- `RESEARCH.md` — raw research data from ~55 open-source repos behind the template's design
- `.github/ISSUE_TEMPLATE/{bug_report,feature_request,new_skill}.md`
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/FUNDING.yml`
- `.github/workflows/lint.yml` — CI: JSON validation for `settings.json`, `shellcheck -S error` on hook scripts, required-field frontmatter check on skills / agents / rules, and a baseline secret scan (hardcoded IPv4, secret-looking env assignments, PEM private-key headers)

[Unreleased]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/felixhennequin-gif/claude-code-config-template/releases/tag/v0.1.0
