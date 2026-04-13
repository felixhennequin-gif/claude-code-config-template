# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **Note:** Versions 0.1.0 through 0.5.0 were developed in an intensive single-day sprint
> and represent logical stages of the initial build, not separate calendar releases.
> Real iterative development begins with post-0.5.0 changes in [Unreleased].

## [Unreleased]

## [0.6.0] — 2026-04-13

### Added
- `.claude/skills/core/debugging/SKILL.md` — second core behavioral skill enforcing a structured debugging workflow (reproduce → read → trace → one-change → three-strike rule). Activates on bugs, errors, and failed test investigations.
- `.claude/hooks/notification.sh` + `Notification` event registration — desktop notification when Claude needs attention during long autonomous tasks. Cross-platform (notify-send / osascript / silent fallback).
- `template/.claudeignore` — stack-agnostic ignore list for `node_modules`, build output, lockfiles, and other noise. The single highest-ROI token-saving measure. The CLI now copies it alongside `CLAUDE.md`.
- `docs/VALIDATION.md` — placeholder for real-world validation results (token deltas, hook catches, skill activations) to replace credibility-by-claim with credibility-by-measurement.
- CI: "Check CLI template sync" step in `.github/workflows/lint.yml` — runs `cli/sync-templates.sh` and fails if `cli/template-files/` drifts from source. Prevents silent CLI/template divergence.
- `prisma-patterns`: `typedSql` guidance (Prisma 7+) — prefer `$queryRawTyped()` with `.sql` files over `$queryRaw` template literals for type-safe raw SQL.

### Changed
- `.claude/rules/test-files.md`: replaced hardcoded Vitest/Supertest/Testing Library framework list with stack-agnostic guidance ("use the project's existing runner — check `package.json`/`Makefile`/`pyproject.toml`"). Test conventions now ship unchanged for Python, Go, Rust, etc.
- `react-frontend`: React Compiler bullet is now conditional on detecting `babel-plugin-react-compiler` or the Vite `reactCompiler` plugin, instead of recommending it unconditionally (it's still experimental in React 19).
- `docs/CONTEXT-BUDGET.md`: replaced the unverifiable "How to measure" section with "How to estimate" — three concrete techniques (file size × 0.25, `wc -w`, ccusage before/after) the user can actually run. Added `.claudeignore` ROI callout.
- `RESEARCH.md`: dropped the "~55 repos" framing throughout and added a collapsible list of the 15 actually-verified repos. Credibility now matches evidence.
- `README.md`: directory tree updated for `.claudeignore`, `VALIDATION.md`, and the `Notification` event. Permissions table documents the stack-agnostic default and how the CLI injects stack permissions.
- `CHANGELOG.md`: added sprint-velocity note explaining that v0.1.0–v0.5.0 were logical stages of a single-day initial build, not separate calendar releases.

### Removed
- `fastapi-backend` skill (`.claude/skills/stacks/fastapi-backend/`) — quality was below the template bar (0 code examples, missing modern patterns like `lifespan` and `Annotated[]` DI). Kept `examples/fastapi-backend.CLAUDE.md` as a reference; contributions welcome for a rewrite that matches the Express/React skills.

### Fixed
- `bash-safety.sh`: replaced literal-substring matching with surgical regex so `rm -rf ./dist`, `git push --force-with-lease`, and `npm publish --dry-run` no longer false-positive. Hook now fails closed on empty/unparseable stdin instead of silently passing.
- `.claude/settings.json`: stripped Node-specific entries from `permissions.allow` and the redundant `Bash(rm -rf:*)` deny entry. Template now ships truly stack-agnostic permissions. README documents how to add stack-specific entries; the CLI injects them automatically based on selected stacks.

## [0.5.0] — 2026-04-13

### Added
- **`create-claude-code-config` CLI** — interactive scaffolding tool
  - `npx create-claude-code-config` to scaffold a Claude Code config
  - Prompts for project directory + stack selection (Express, Prisma, React, FastAPI)
  - Copies CLAUDE.md, .claude/ (hooks, commands, rules, skills), CLAUDE.local.md
  - Removes unselected stack skills automatically
  - Updates .gitignore with personal file entries
  - Ships template files embedded — no runtime git clone
- `cli/sync-templates.sh` script to keep CLI templates in sync with repo

### Changed
- README: installation now offers CLI (Option A) and manual (Option B)
- README: directory tree updated with `cli/`
- Root CLAUDE.md: added CLI section with contributor guidance

## [0.4.0] — 2026-04-13

### Fixed (v0.3.1)
- `stacks/README.md`: added fastapi-backend, removed from wanted list
- `examples/agents/`: moved HTML comment after frontmatter (runtime parsing fix)
- `session-start.sh`: fixed pipefail crash on repos with zero TODOs
- `CONTRIBUTING.md`: fixed skill path references, removed `allowed-tools` from example
- `deploy.md`: replaced hardcoded paths with placeholder variables
- `test-files.md`: added `name:` field for consistency
- `express-api` + `prisma-patterns`: removed `allowed-tools` (consistent with v0.2.0)
- README: added note about editing stack-specific permissions

### Added
- "What this changes vs bare Claude Code" comparison table in README
- "Compared to alternatives" section in README with competitive positioning
- `examples/agents/README.md` explaining the example agents
- `examples/go-api.CLAUDE.md` — Go/Chi/sqlc example (3rd stack coverage)
- Starter gotchas in `template/CLAUDE.md` (no longer fully commented out)

### Changed
- README: directory tree updated with Go example
- "Missing your stack?" list updated (removed Go and FastAPI)

## [0.3.0] — 2026-04-13

### Fixed (v0.2.1 scope)
- README: directory tree now matches actual v0.2.0+ structure (was still showing v0.1.x layout)
- Fixed git remote URL (was pointing to the old `ai-config-template.git` name)
- Cleaned up stale feature branches (`feat/v0.2.0`, `fix/ci-frontmatter`)
- Verified no remaining "production-ready" references in non-historic tracked files

### Added
- **Python/FastAPI support** — new stack skill at `.claude/skills/stacks/fastapi-backend/SKILL.md` (SQLAlchemy 2.x async, Alembic, Pydantic v2 conventions) and example config at `examples/fastapi-backend.CLAUDE.md`.
- **Context budget guide** (`docs/CONTEXT-BUDGET.md`) — per-component token estimates, three budget profiles (minimal/standard/full), and rules of thumb for pruning skills.
- **Banned-patterns rule** (`.claude/rules/banned-patterns.md`) — universal + JS/TS + Python anti-patterns, scoped via `globs:` to the matching file types.
- **"Adding a new stack" section in CONTRIBUTING.md** — three-step recipe (skill → example → optional agent) and the 80-line rule.
- Principle #7 in README: "Know your token budget" with a pointer to `docs/CONTEXT-BUDGET.md`.

### Changed
- **RESEARCH.md rewritten in full** — replaced the "55 repos with star counts" credibility padding with six concrete findings, each tied to a template decision (CLAUDE.md length, skills beat inline, hooks underused, agents need project context, core/stacks split, repo rot), an anti-patterns-avoided list, and a focused sources table.
- README: added FastAPI to the stack skills table, removed FastAPI from the "contributions welcome" list.
- Root `CLAUDE.md`: directory tree and rules listing updated for `banned-patterns.md`, `fastapi-backend`, and `docs/`.

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

[Unreleased]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/felixhennequin-gif/claude-code-config-template/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/felixhennequin-gif/claude-code-config-template/releases/tag/v0.1.0
