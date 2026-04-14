# claude-code-config-template

An opinionated Claude Code starter template for any project. The core — `template/CLAUDE.md`, hooks, commands, rules, and the universal skills under `.claude/skills/core/` (`coding-principles`, `debugging`, `error-handling`, `testing`) — is stack-agnostic. Stack-specific conventions live under `.claude/skills/stacks/` and are optional. Default subagents ship as examples under `examples/agents/` (Node/React/PostgreSQL-flavored) — `.claude/agents/` is empty by default so it never ships stack assumptions downstream.

This `CLAUDE.md` is **not** the downstream-facing template — it's the one Claude Code loads when working *on this repo*. The downstream template lives at [`template/CLAUDE.md`](./template/CLAUDE.md).

## What this repo ships

- **`template/CLAUDE.md`** — the stack-agnostic placeholder project context users copy into their own projects
- **`template/CLAUDE.local.md.example`** — the personal-override template users copy to `CLAUDE.local.md` (which is gitignored)
- **`.claude/skills/core/`** — universal behavioral skills that ship with every install: `coding-principles`, `debugging`, `error-handling`, `testing`
- **`.claude/skills/stacks/`** — optional stack-specific skills (currently `prisma-patterns`, `express-api`, `react-frontend`); users delete the whole directory or keep a subset
- **`.claude/` (rest)** — hooks (lint-on-edit, session-start, bash-safety), commands, and rules, all stack-agnostic
- **`.claude/agents/`** — empty by default, just a README pointing to `examples/agents/`
- **`examples/*.CLAUDE.md`** — stack-specific ready-to-adapt alternatives to `template/CLAUDE.md`
- **`examples/agents/`** — Node/React/PostgreSQL-flavored subagents (`reviewer`, `security-auditor`) users copy into `.claude/agents/` and edit for their stack
- **Community infra** — `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, `CHANGELOG.md`, `.github/` templates
- **`RESEARCH.md`** — raw research data behind the template's design choices

## Structure

```
CLAUDE.md                       # You are here — context for working on this repo
README.md                       # User-facing landing page
template/
  CLAUDE.md                     # Downstream-facing blank template
  CLAUDE.local.md.example       # Tracked template for personal overrides
  .claudeignore                 # Ignore list (node_modules, dist, lockfiles, etc.)
.claude/
  settings.json                 # SessionStart + PreToolUse (main/master guard, bash safety) + PostToolUse lint
  agents/
    README.md                   # Empty by default — pointer to examples/agents/
  commands/                     # /audit, /deploy, /test, /wrap (stack-agnostic, configurable paths)
  skills/
    core/
      README.md                 # What "core" means
      coding-principles/        # Universal behavioral skill (always copy)
      debugging/                # Structured debugging workflow (always copy)
      error-handling/           # Universal error-handling patterns (always copy)
      testing/                  # Testing strategy and decisions (always copy)
    stacks/
      README.md                 # What "stacks" means
      prisma-patterns/          # Optional
      express-api/              # Optional
      react-frontend/           # Optional
  hooks/
    lint-on-edit.sh             # Stdin-parsing ESLint hook (PostToolUse)
    session-start.sh            # Injects git context (SessionStart)
    bash-safety.sh              # Blocks destructive commands (PreToolUse Bash)
    notification.sh             # Desktop alert when Claude waits for input (Notification)
  rules/
    test-files.md               # Scoped rules for *.test.*, *.spec.*
    banned-patterns.md          # Universal + JS/TS anti-patterns
    banned-patterns-python.md   # Python-specific anti-patterns
docs/
  CONTEXT-BUDGET.md             # Token estimates per component + budget profiles
  VALIDATION.md                 # Real-world test results template (fill after testing)
examples/
  README.md                     # Index + usage instructions
  express-api.CLAUDE.md         # Under 80 lines, concrete gotchas
  nextjs-fullstack.CLAUDE.md    # Under 80 lines, concrete gotchas
  fastapi-backend.CLAUDE.md     # Python/FastAPI example (added v0.3.0)
  go-api.CLAUDE.md              # Go/Chi/sqlc example (added v0.4.0)
  agents/
    README.md                   # Index of example agents (added v0.4.0)
    reviewer.md                 # Node/React/PostgreSQL example subagent
    security-auditor.md         # Node/React/PostgreSQL example subagent
.github/
  ISSUE_TEMPLATE/               # bug_report, feature_request, new_skill
  PULL_REQUEST_TEMPLATE.md
  FUNDING.yml
```

## CLI (`cli/`)

The `create-claude-code-config` npm package lives here. It's published independently but shares this repo.

- Entry point: `cli/bin/create-claude-code-config.js`
- Template files are embedded in `cli/template-files/` — these are copies of `template/` and `.claude/`
- After any change to template files, skills, hooks, rules, or commands: run `bash cli/sync-templates.sh` to re-copy them into `cli/template-files/`
- CI will fail if `cli/template-files/` diverges from the source files. Always run `bash cli/sync-templates.sh` after editing template content.
- The CLI has one dependency: `prompts`
- Test locally with `cd cli && node bin/create-claude-code-config.js`

## Working on this repo

No build step in the root — every file is Markdown, JSON, or shell. The `cli/` subdirectory has its own `package.json`. Most changes are content quality, not code.

```bash
# Validate settings.json
python3 -c "import json; json.load(open('.claude/settings.json'))"

# Syntax-check hooks
bash -n .claude/hooks/lint-on-edit.sh .claude/hooks/session-start.sh .claude/hooks/bash-safety.sh

# Smoke-test the lint hook with a sample payload
echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.js"}}' | bash .claude/hooks/lint-on-edit.sh

# Smoke-test bash-safety — every case below must produce the expected exit code.
# Should PASS (exit 0) — routine dev commands that previously false-positived:
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ./dist"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ./node_modules"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf .cache"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force-with-lease origin main"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"npm publish --dry-run"}}' | bash .claude/hooks/bash-safety.sh

# Should BLOCK (exit 2) — genuinely dangerous:
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ~"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ."}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push -f origin main"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"npm publish"}}' | bash .claude/hooks/bash-safety.sh
echo '{"tool_name":"Bash","tool_input":{"command":"dd if=/dev/zero of=/dev/sda"}}' | bash .claude/hooks/bash-safety.sh

# Should BLOCK (exit 2) — fail-closed on unparseable input:
echo 'not json at all' | bash .claude/hooks/bash-safety.sh
echo '' | bash .claude/hooks/bash-safety.sh
```

## Conventions specific to this repo

- **Every file is downstream-facing template content.** Assume strangers will read it, copy it, and debug it. No personal names, IPs, hostnames, internal project references, or business context anywhere in `template/`, `.claude/`, or `examples/`.
- **Owner identity is allowed only where it's structurally required**: `LICENSE` (copyright), `SECURITY.md` (contact), `CODE_OF_CONDUCT.md` (contact), `.github/FUNDING.yml`, and the repo-URL links in `README.md` / `CHANGELOG.md`.
- **Skills and agents must trigger on concrete situations.** The `description` frontmatter is the only signal Claude has for when to activate them — vague descriptions are bugs.
- **Anti-patterns sections are the highest-ROI content in a skill.** If a skill lacks one, it's incomplete.
- **Keep `template/CLAUDE.md` under ~80 lines** and examples under ~80 lines — Claude Code drops context beyond that.
- **Don't duplicate linters.** If ESLint / Prettier / the hook already enforces a rule, don't write it into a skill.
- **Conventions across files must agree.** A contradiction between a skill and an agent is a bug (see past incident in `CHANGELOG.md` Unreleased: `reviewer` vs `express-api` on `try/catch`).
- **Core vs. stacks/ split is load-bearing.** `.claude/skills/core/` (currently `coding-principles`, `debugging`, `error-handling`, `testing`) and everything outside `.claude/skills/stacks/` must stay stack-agnostic so downstream users on any language can install them untouched. Anything Node/Python/Go/Rust-specific belongs under `.claude/skills/stacks/<name>/` or — for subagents — `examples/agents/`.
- **`.claude/agents/` is empty by default.** Stack-flavored subagents live under `examples/agents/` and must include a `<!-- Example agent for <stack>... -->` header comment. Don't re-add defaults to `.claude/agents/` without making them truly stack-agnostic.

## Git workflow

- `master` = the only branch (protected in intent, though not yet enforced).
- Feature work on `feat/xxx`, fixes on `fix/xxx`, docs on `docs/xxx`.
- Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`.
- One logical change per commit — don't bundle a skill addition with an unrelated hook fix.
- The PreToolUse hook in `.claude/settings.json` blocks edits while on `main` or `master`. Since this repo's default branch is `master`, **all structural work must happen on a `feat/`, `fix/`, or `docs/` branch** — the guard is live here, not just for downstream users.

## Gotchas

- **`CLAUDE.local.md` is gitignored**, so it's absent from fresh clones. The downstream template users actually receive is `template/CLAUDE.local.md.example`. The install snippet in `README.md` must reflect this — don't regress it.
- **`lint-on-edit.sh` parses its payload from stdin**, not env vars. Claude Code used to expose env vars, but no longer — the hook was fixed for this in commit `ca8ecf8`. If you refactor the hook, keep the stdin path.
- **PreToolUse main/master guard uses `git branch --show-current`** inside a `case` statement. A detached HEAD returns empty and passes the guard — intentional, don't "fix" it.
- **`bash-safety.sh` must not be "improved" to block more patterns without testing.** `grep -qF` is literal-match by design — regex escapes like `\.` will be treated as literal backslash-dot and miss real matches. Add a smoke test in `CLAUDE.md` → "Working on this repo" before any pattern additions.
- **Frontmatter in `.claude/rules/*.md` uses `globs:` (not `applyTo:`)** — this is the format Claude Code actually reads. Don't rename it.
- **The repo's root `CLAUDE.md` is this file, not the downstream template.** Don't accidentally blank it out when editing the downstream template at `template/CLAUDE.md`.

## References

- [`CONTRIBUTING.md`](./CONTRIBUTING.md) — what the quality bar is for skills, agents, commands, examples
- [`RESEARCH.md`](./RESEARCH.md) — findings from analyzing notable Claude Code configs (rewritten in v0.3.0 to focus on conclusions instead of raw repo lists; repo list added in the Unreleased phase-2 docs pass)
- [`docs/CONTEXT-BUDGET.md`](./docs/CONTEXT-BUDGET.md) — per-component token estimates and budget profiles for pruning skills
- [`CHANGELOG.md`](./CHANGELOG.md) — what changed, including the `[Unreleased]` section for in-flight work
- [Claude Code docs](https://docs.claude.com/en/docs/claude-code) — upstream source of truth for hook/settings/agent syntax
