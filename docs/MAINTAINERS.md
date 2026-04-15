# Maintainers guide — claude-code-config-template

Reference for contributors working *on this repo*. This file used to live at the repo root as `CLAUDE.md` (auto-loaded by Claude Code); it was moved here so the root no longer doubles as both contributor context and a file downstream users confuse with [`template/CLAUDE.md`](../template/CLAUDE.md) (the one they copy into their own project).

To load this file as context when working on the repo, reference it explicitly at the start of a session (e.g. "read docs/MAINTAINERS.md first") or add a symlink at `CLAUDE.md` → `docs/MAINTAINERS.md` locally.

Core content (always ships, stack-agnostic): `template/CLAUDE.md`, hooks, commands, rules, and the universal skills under `.claude/skills/core/` (`coding-principles`, `debugging`, `error-handling`, `testing`, `git-workflow`, `code-review`). Stack-specific skills under `.claude/skills/stacks/` are optional. `.claude/agents/` ships two stack-agnostic defaults — `reviewer` (code-level review) and `architect` (structural review) — and stack-flavored subagents (Node/Prisma reviewer, security auditor, etc.) live under `examples/agents/` and are opt-in.

## Structure

```
template/                         # Downstream-facing blank template (CLAUDE.md, .claudeignore, local override)
.claude/
  settings.json                   # SessionStart + PreToolUse guards + PostToolUse lint
  agents/                         # reviewer + architect (stack-agnostic defaults); examples/agents/ for stack-flavored
  commands/                       # /audit, /deploy, /lint-config, /skill-check
  skills/core/                    # coding-principles, debugging, error-handling, testing, git-workflow, code-review
  skills/stacks/                  # prisma-patterns, express-api, react-frontend, symfony-api, ci-cd-pipeline
  hooks/                          # lint-on-edit, session-start, dangerous-rm-guard, notification
  rules/                          # banned-patterns, git-workflow, test-files
docs/                             # CONTEXT-BUDGET.md, VALIDATION.md, HACKING.md (working-on-this-repo guide)
examples/routines/ + ROUTINES.md  # Speculative-preview cloud automation prompts (not CLI-copied)
examples/                         # CLAUDE.md examples (express, next, fastapi, go, symfony) + example subagents
cli/                              # create-claude-code-config npm package; template-files/ mirrors .claude/ and template/
```

## Working on this repo

No build step — every file is Markdown, JSON, or shell. `make check` runs the same static checks as CI (JSON, shellcheck, frontmatter, template sync) plus the hook smoke tests; run it before committing. Individual targets: `make lint`, `make test-hooks`, `make sync`. Always run `bash cli/sync-templates.sh` after editing anything under `template/` or `.claude/` — CI fails if `cli/template-files/` drifts. Detailed smoke-test recipes and CLI notes live in [`HACKING.md`](./HACKING.md).

## Conventions specific to this repo

- **Every file is downstream-facing template content.** No personal names, IPs, hostnames, internal projects, or business context anywhere in `template/`, `.claude/`, or `examples/`. Owner identity is allowed only where structurally required (`LICENSE`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `.github/FUNDING.yml`, README repo URLs).
- **Skills and agents must trigger on concrete situations.** The `description` frontmatter is the only signal Claude has for when to activate them — vague descriptions are bugs. Every skill needs an Anti-patterns section.
- **Keep `template/CLAUDE.md` and every file in `examples/` ≤ 80 lines** — Claude Code drops context beyond that. This file is held to the same ceiling.
- **Don't duplicate linters.** If ESLint / Prettier / a hook already enforces a rule, don't re-write it into a skill.
- **Conventions across files must agree.** A contradiction between a skill and an agent is a bug (see past `reviewer` vs `express-api` incident in `CHANGELOG.md`).
- **Core vs. stacks/ split is load-bearing.** `.claude/skills/core/` and everything outside `.claude/skills/stacks/` must stay stack-agnostic so any language can install it untouched. Language/framework/CI specifics belong under `.claude/skills/stacks/<name>/` or `examples/agents/`. `ci-cd-pipeline` sits under `stacks/` because its snippets assume GitHub Actions or GitLab CI.
- **`.claude/agents/` ships two stack-agnostic defaults (`reviewer.md` and `architect.md`).** Both must stay framework-free: they may reference `.claude/rules/banned-patterns.md`, `CLAUDE.md`, and whichever stack skills happen to be present, but never a specific ORM, framework, or language. `reviewer` catches code-level issues (banned patterns, security, error handling, test coverage); `architect` catches structural ones (layering, separation of concerns, dependency direction, pattern consistency) — keep the split clean so each agent stays under the 80-line ceiling and their checklists don't overlap. Stack-flavored subagents stay under `examples/agents/` with a `<!-- Example agent for <stack>... -->` header; don't promote them into `.claude/agents/` without stripping stack assumptions first.

## Git workflow

- `master` = only branch (protected in intent). Feature work on `feat/xxx`, fixes on `fix/xxx`, docs on `docs/xxx`. Conventional Commits.
- One logical change per commit — don't bundle a skill addition with an unrelated hook fix.
- The PreToolUse hook blocks edits while on `main`/`master`, so all structural work must happen on a `feat/`, `fix/`, or `docs/` branch. See [`.claude/rules/git-workflow.md`](../.claude/rules/git-workflow.md) — merging is always the user's job.

## Gotchas

- **`CLAUDE.local.md` is gitignored** — downstream users actually receive `template/CLAUDE.local.md.example`. The install snippet in `README.md` must reflect this; `session-start.sh` prints a reminder each session when the file is missing — don't suppress it.
- **`lint-on-edit.sh` and `dangerous-rm-guard.sh` parse stdin with an inline awk helper**, not jq or node. `awk` is POSIX base and universally present; the two previous fallbacks (jq → node) baked a Node.js assumption into a repo that claims to be stack-agnostic. If you refactor either hook, keep the awk path and don't reintroduce language-specific JSON parsers. The helper is inlined (not a shared file) because hooks are meant to be standalone scripts a user can drop into their own project.
- **PreToolUse main/master guard is opt-in-bypassable.** It blocks edits on `main`/`master` by default, but exporting `ALLOW_MAIN_EDIT=true` short-circuits the check — useful for solo repos or docs-only commits. Known limitation: the guard uses `git branch --show-current`, which returns empty under detached HEAD, so the check silently passes in that state. This is a gap, not a feature — if you need to plug it, also check `git rev-parse HEAD` against the tip of `main`/`master`.
- **`dangerous-rm-guard.sh` uses literal-match `grep -qF`** — regex escapes like `\.` are treated literally. Re-run the smoke tests in [`HACKING.md`](./HACKING.md) before any pattern addition.
- **`git reset --hard` / `git clean -fd` / `git branch -D` / `git checkout --` are intentionally excluded from the permissions allowlist.** `settings.json` lists safe git subcommands explicitly — don't "simplify" back to `Bash(git:*)`.
- **Frontmatter in `.claude/rules/*.md` uses `paths:`** (Claude Code native), not `globs:` (Cursor convention, silently ignored). Rules without `paths:` load unconditionally.
- **Settings precedence**: `~/.claude/settings.json` → `.claude/settings.json` → `.claude/settings.local.json`, later wins. Don't assume the project file is the full allowlist when debugging permissions.
- **This file (`docs/MAINTAINERS.md`) is the contributor guide, not `template/CLAUDE.md`.** Downstream users copy `template/CLAUDE.md` into their own project — don't conflate the two. The repo root intentionally has no `CLAUDE.md` so there's no ambiguity about which file to copy.

## References

- [`HACKING.md`](./HACKING.md) — working-on-this-repo guide (smoke tests, CLI notes)
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — quality bar for skills, agents, commands, examples
- [`CONTEXT-BUDGET.md`](./CONTEXT-BUDGET.md) — per-component token budgets
- [`../CHANGELOG.md`](../CHANGELOG.md) — what changed, including `[Unreleased]` for in-flight work
- [Claude Code docs](https://docs.claude.com/en/docs/claude-code) — upstream source of truth for hook/settings/agent syntax
