# claude-code-config-template

A public, reusable Claude Code configuration template for Node.js / React / PostgreSQL projects. Downstream users copy `template/CLAUDE.md` and `.claude/` into their own repo and get hooks, agents, skills, commands, and rules out of the box.

This `CLAUDE.md` is **not** the downstream-facing template — it's the one Claude Code loads when working *on this repo*. The downstream template lives at [`template/CLAUDE.md`](./template/CLAUDE.md).

## What this repo ships

- **`template/CLAUDE.md`** — the placeholder project context users copy into their own projects
- **`CLAUDE.local.md.example`** — the personal-override template users copy to `CLAUDE.local.md` (which is gitignored)
- **`.claude/`** — hooks, agents, skills, commands, and rules that get copied alongside
- **`examples/*.CLAUDE.md`** — stack-specific ready-to-adapt alternatives to `template/CLAUDE.md`
- **Community infra** — `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md`, `.github/` templates
- **`RESEARCH.md`** — raw research data behind the template's design choices

## Structure

```
CLAUDE.md                       # You are here — context for working on this repo
README.md                       # User-facing landing page
template/
  CLAUDE.md                     # Downstream-facing blank template
CLAUDE.local.md.example         # Tracked template for personal overrides
.claude/
  settings.json                 # PreToolUse main-branch guard + PostToolUse lint hook
  agents/                       # reviewer, security-auditor
  commands/                     # /audit, /deploy, /test
  skills/                       # prisma-patterns, express-api, react-frontend
  hooks/lint-on-edit.sh         # Stdin-parsing ESLint hook
  rules/test-files.md           # Scoped rules for *.test.*, *.spec.*
examples/
  README.md                     # Index + usage instructions
  express-api.CLAUDE.md         # Under 80 lines, concrete gotchas
  nextjs-fullstack.CLAUDE.md    # Under 80 lines, concrete gotchas
.github/
  ISSUE_TEMPLATE/               # bug_report, feature_request, new_skill
  PULL_REQUEST_TEMPLATE.md
  FUNDING.yml
```

## Working on this repo

No build step, no package.json — every file is Markdown, JSON, or shell. Most changes are content quality, not code.

```bash
# Validate settings.json
python3 -c "import json; json.load(open('.claude/settings.json'))"

# Syntax-check the hook
bash -n .claude/hooks/lint-on-edit.sh

# Smoke-test the hook with a sample payload
echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.js"}}' | bash .claude/hooks/lint-on-edit.sh
```

## Conventions specific to this repo

- **Every file is downstream-facing template content.** Assume strangers will read it, copy it, and debug it. No personal names, IPs, hostnames, internal project references, or business context anywhere in `template/`, `.claude/`, or `examples/`.
- **Owner identity is allowed only where it's structurally required**: `LICENSE` (copyright), `SECURITY.md` (contact), `CODE_OF_CONDUCT.md` (contact), `.github/FUNDING.yml`, and the repo-URL links in `README.md` / `CHANGELOG.md`.
- **Skills and agents must trigger on concrete situations.** The `description` frontmatter is the only signal Claude has for when to activate them — vague descriptions are bugs.
- **Anti-patterns sections are the highest-ROI content in a skill.** If a skill lacks one, it's incomplete.
- **Keep `template/CLAUDE.md` under ~80 lines** and examples under ~80 lines — Claude Code drops context beyond that.
- **Don't duplicate linters.** If ESLint / Prettier / the hook already enforces a rule, don't write it into a skill.
- **Conventions across files must agree.** A contradiction between a skill and an agent is a bug (see past incident in `CHANGELOG.md` Unreleased: `reviewer` vs `express-api` on `try/catch`).

## Git workflow

- `master` = the only branch (protected in intent, though not yet enforced).
- Feature work on `feat/xxx`, fixes on `fix/xxx`, docs on `docs/xxx`.
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`.
- One logical change per commit — don't bundle a skill addition with an unrelated hook fix.
- The PreToolUse hook in `.claude/settings.json` blocks edits while on `main`. This repo uses `master`, so the guard is currently inert here but real for downstream users.

## Gotchas

- **`CLAUDE.local.md` is gitignored**, so it's absent from fresh clones. The downstream template users actually receive is `CLAUDE.local.md.example`. The install snippet in `README.md` must reflect this — don't regress it.
- **`lint-on-edit.sh` parses its payload from stdin**, not env vars. Claude Code used to expose env vars, but no longer — the hook was fixed for this in commit `ca8ecf8`. If you refactor the hook, keep the stdin path.
- **PreToolUse hook uses `git branch --show-current`** and short-circuits via `[ ... ] || { ...; exit 2; }`. A detached HEAD returns empty and passes the guard — intentional, don't "fix" it.
- **Frontmatter in `.claude/rules/*.md` uses `globs:` (not `applyTo:`)** — this is the format Claude Code actually reads. Don't rename it.
- **The repo's root `CLAUDE.md` is this file, not the downstream template.** Don't accidentally blank it out when editing the downstream template at `template/CLAUDE.md`.

## References

- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — what the quality bar is for skills, agents, commands, examples
- [`RESEARCH.md`](./RESEARCH.md) — the raw data that shaped the template's design
- [`CHANGELOG.md`](./CHANGELOG.md) — what changed, including the `[Unreleased]` section for in-flight work
- [Claude Code docs](https://docs.claude.com/en/docs/claude-code) — upstream source of truth for hook/settings/agent syntax
