# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] — 2026-04-13

### Changed

- **BREAKING**: Skills restructured — `coding-principles` moved to `.claude/skills/core/coding-principles/`. Core-vs-stacks split is now reflected on disk, so downstream users can prune `stacks/` wholesale without touching universal behavioral rules.
- **BREAKING**: Default agents moved to `examples/agents/` — they were Node/React/PostgreSQL-specific and contradicted the "any project" positioning. `.claude/agents/` is now empty by default with a README explaining how to copy them back.
- README: dropped "production-ready" framing, restructured for action-first flow (install snippet first, principles up top, then directory tree).
- `.claude/settings.json`: `PreToolUse` branch guard now blocks edits on both `main` AND `master`.
- `coding-principles` SKILL: removed the `allowed-tools: Read, Grep, Glob` frontmatter (contradicted its purpose as a behavioral skill for code edits) and cut generic advice already covered by Claude's training. Now 47 lines.
- `react-frontend` SKILL: fixed the incorrect "no Zustand unless > 5 contexts" rule (Context re-renders every consumer on every update — Zustand's selectors are the right tool for high-frequency shared state). Added a React 19 section (`use()`, `useActionState`, `useFormStatus`, Server Components boundary, React Compiler).
- `.claude/commands/audit.md` and `test.md`: replaced hardcoded `backend/`, `frontend/`, `prisma/schema.prisma`, and `npm test -- --coverage` paths with configurable placeholder variables and stack-agnostic instructions.

### Added

- `.claude/hooks/session-start.sh` + `SessionStart` hook registration — injects branch, last commit, uncommitted changes, and TODO count at session start.
- `.claude/hooks/bash-safety.sh` + `PreToolUse` Bash matcher — blocks `rm -rf /`, `rm -rf ~`, `git push --force`, `npm publish`, `mkfs.`, `dd if=`, fork-bomb, etc. Merged alongside the existing main-branch guard, not overwriting it.
- MCP integration section in README (pointer + example `.mcp.json`, explanation of why it's not shipped by default).
- `.claude/skills/core/README.md`, `.claude/skills/stacks/README.md`, and `.claude/agents/README.md` — each explains the directory's purpose and how to prune or extend it.

### Removed

- Default `.claude/agents/reviewer.md` and `.claude/agents/security-auditor.md` (moved to `examples/agents/` with a "Node.js/React/PostgreSQL example — edit for your stack" comment at the top).
- Generic advice from `coding-principles` that duplicated Claude's training (e.g. "state assumptions", explicit scope section).
- `allowed-tools` frontmatter from `coding-principles` and `react-frontend` SKILL files.

## [0.1.2] — 2026-04-13

### Changed

- **Template repositioned as stack-agnostic.** README one-liner now describes the project as "Production-ready AI config template for Claude Code — agents, skills, hooks, and commands for any project." instead of "Node.js / React / PostgreSQL".
- `template/CLAUDE.md` rewritten with stack placeholders (`[your language]`, `[your framework]`, etc.) so it's fillable for Node, Python, Go, Rust, Ruby, PHP, JVM, or anything else. Section structure (Stack, Structure, Commands, Conventions, Git workflow, Gotchas, References) is unchanged — only the Node/Express/Prisma/React anchors were removed.
- `.claude/skills/` reorganized: universal skills stay at the top level (`coding-principles/`), stack-specific skills moved under `.claude/skills/stacks/` (`prisma-patterns/`, `express-api/`, `react-frontend/`). Downstream users can delete `stacks/` wholesale or prune individually. History preserved via `git mv`.
- Install snippet split into "Quick start — core (always)" and "Add stack skills (optional)". README now lists the available stack skills in a table with their trigger conditions and links to each `SKILL.md`.
- Root `CLAUDE.md` now describes the core-vs-stacks split as a load-bearing repo convention so future contributions don't leak stack-specific content back into the core.
- `examples/README.md` explicitly invites examples for Python, Ruby, Go, Rust, PHP, JVM, and alt-JS frameworks — the only examples that currently ship are Node-flavored (Express, Next.js).
- Path references updated in `coding-principles/SKILL.md` and `.github/ISSUE_TEMPLATE/bug_report.md` to match the new `skills/stacks/` layout.

## [0.1.1] — 2026-04-13

### Added

- `.claude/skills/core/coding-principles/SKILL.md` — stack-agnostic behavioral skill condensing Andrej Karpathy's four coding principles (think before coding, simplicity first, surgical changes, goal-driven execution) into actionable rules with concrete "senior engineer" tests. Adapted from [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills). Triggers on every coding task and cross-references the stack-specific skills.

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

[Unreleased]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/felixhennequin-gif/claude-code-config-template/releases/tag/v0.1.0
