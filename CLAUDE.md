# claude-code-config-template

Opinionated Claude Code starter template. This file is the context Claude Code loads when working *on this repo*; the downstream-facing template lives at [`template/CLAUDE.md`](./template/CLAUDE.md).

Core content (always ships, stack-agnostic): `template/CLAUDE.md`, hooks, commands, rules, and the universal skills under `.claude/skills/core/` (`coding-principles`, `debugging`, `error-handling`, `testing`, `git-workflow`, `code-review`). Stack-specific skills under `.claude/skills/stacks/` are optional. Stack-flavored subagents live under `examples/agents/` — `.claude/agents/` is empty by default so it never ships stack assumptions downstream.

## Structure

```
template/                         # Downstream-facing blank template (CLAUDE.md, .claudeignore, local override)
.claude/
  settings.json                   # SessionStart + PreToolUse guards + PostToolUse lint
  agents/README.md                # Empty by default — points at examples/agents/
  commands/                       # /audit, /deploy, /lint-config, /skill-check, /test, /wrap
  skills/core/                    # coding-principles, debugging, error-handling, testing, git-workflow, code-review
  skills/stacks/                  # prisma-patterns, express-api, react-frontend, symfony-api, ci-cd-pipeline
  hooks/                          # lint-on-edit, session-start, dangerous-rm-guard, notification
  rules/                          # banned-patterns, git-workflow, test-files
docs/                             # CONTEXT-BUDGET.md, VALIDATION.md, HACKING.md (working-on-this-repo guide)
examples/routines/ + ROUTINES.md  # Speculative-preview cloud automation prompts (not CLI-copied)
registry.yaml                     # Machine-readable index of every skill/agent/command/routine (CI-enforced)
examples/                         # CLAUDE.md examples (express, next, fastapi, go, symfony) + example subagents
cli/                              # create-claude-code-config npm package; template-files/ mirrors .claude/ and template/
```

## Working on this repo

No build step — every file is Markdown, JSON, or shell. `make check` runs the same static checks as CI (JSON, shellcheck, frontmatter, registry, template sync) plus the hook smoke tests; run it before committing. Individual targets: `make lint`, `make test-hooks`, `make sync`. Always run `bash cli/sync-templates.sh` after editing anything under `template/` or `.claude/` — CI fails if `cli/template-files/` drifts. Detailed smoke-test recipes and CLI notes live in [`docs/HACKING.md`](./docs/HACKING.md).

## Conventions specific to this repo

- **Every file is downstream-facing template content.** No personal names, IPs, hostnames, internal projects, or business context anywhere in `template/`, `.claude/`, or `examples/`. Owner identity is allowed only where structurally required (`LICENSE`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `.github/FUNDING.yml`, README repo URLs).
- **Skills and agents must trigger on concrete situations.** The `description` frontmatter is the only signal Claude has for when to activate them — vague descriptions are bugs. Every skill needs an Anti-patterns section.
- **Keep `template/CLAUDE.md` and every file in `examples/` ≤ 80 lines** — Claude Code drops context beyond that. This root `CLAUDE.md` is held to the same ceiling.
- **Don't duplicate linters.** If ESLint / Prettier / a hook already enforces a rule, don't re-write it into a skill.
- **Conventions across files must agree.** A contradiction between a skill and an agent is a bug (see past `reviewer` vs `express-api` incident in `CHANGELOG.md`).
- **Core vs. stacks/ split is load-bearing.** `.claude/skills/core/` and everything outside `.claude/skills/stacks/` must stay stack-agnostic so any language can install it untouched. Language/framework/CI specifics belong under `.claude/skills/stacks/<name>/` or `examples/agents/`. `ci-cd-pipeline` sits under `stacks/` because its snippets assume GitHub Actions or GitLab CI.
- **`.claude/agents/` is empty by default.** Stack-flavored subagents live under `examples/agents/` with a `<!-- Example agent for <stack>... -->` header. Don't re-add defaults without making them truly stack-agnostic.

## Git workflow

- `master` = only branch (protected in intent). Feature work on `feat/xxx`, fixes on `fix/xxx`, docs on `docs/xxx`. Conventional Commits.
- One logical change per commit — don't bundle a skill addition with an unrelated hook fix.
- The PreToolUse hook blocks edits while on `main`/`master`, so all structural work must happen on a `feat/`, `fix/`, or `docs/` branch. See [`.claude/rules/git-workflow.md`](./.claude/rules/git-workflow.md) — merging is always the user's job.

## Gotchas

- **`CLAUDE.local.md` is gitignored** — downstream users actually receive `template/CLAUDE.local.md.example`. The install snippet in `README.md` must reflect this; `session-start.sh` prints a reminder each session when the file is missing — don't suppress it.
- **`lint-on-edit.sh` parses its payload from stdin**, not env vars. If you refactor it, keep the stdin path. It covers JS/TS/Python/Go/Rust and each branch gates on `command -v <tool>`, exiting 0 silently if the tool is absent — don't add branches that block on a missing tool.
- **PreToolUse main/master guard** uses `git branch --show-current` inside a `case` statement. Detached HEAD returns empty and passes the guard — intentional, don't "fix" it.
- **`dangerous-rm-guard.sh` uses literal-match `grep -qF`** — regex escapes like `\.` are treated literally. Re-run the smoke tests in [`docs/HACKING.md`](./docs/HACKING.md) before any pattern addition.
- **`git reset --hard` / `git clean -fd` / `git branch -D` / `git checkout --` are intentionally excluded from the permissions allowlist.** `settings.json` lists safe git subcommands explicitly — don't "simplify" back to `Bash(git:*)`.
- **Frontmatter in `.claude/rules/*.md` uses `paths:`** (Claude Code native), not `globs:` (Cursor convention, silently ignored). Rules without `paths:` load unconditionally.
- **Settings precedence**: `~/.claude/settings.json` → `.claude/settings.json` → `.claude/settings.local.json`, later wins. Don't assume the project file is the full allowlist when debugging permissions.
- **The repo's root `CLAUDE.md` is this file, not the downstream template.** Don't blank it out when editing `template/CLAUDE.md`.

## References

- [`docs/HACKING.md`](./docs/HACKING.md) — working-on-this-repo guide (smoke tests, CLI notes)
- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — quality bar for skills, agents, commands, examples
- [`docs/CONTEXT-BUDGET.md`](./docs/CONTEXT-BUDGET.md) — per-component token budgets
- [`CHANGELOG.md`](./CHANGELOG.md) — what changed, including `[Unreleased]` for in-flight work
- [Claude Code docs](https://docs.claude.com/en/docs/claude-code) — upstream source of truth for hook/settings/agent syntax
