# claude-code-config-template

![License](https://img.shields.io/github/license/felixhennequin-gif/claude-code-config-template) ![CI](https://img.shields.io/github/actions/workflow/status/felixhennequin-gif/claude-code-config-template/lint.yml?label=lint) ![GitHub stars](https://img.shields.io/github/stars/felixhennequin-gif/claude-code-config-template?style=social)

> **An opinionated template for Claude Code configuration — not a framework, not a marketplace, not a guide.**

You copy the files into your project, own them, and edit them. There is no runtime, no dependency, and nothing to upgrade. The file you drop into your own project lives at [`template/CLAUDE.md`](./template/CLAUDE.md) — the rest of this repo (skills, hooks, commands, examples) is there for you to cherry-pick or delete.

## Why

Claude Code automatically loads `CLAUDE.md` and `.claude/` at the start of every session. Without them, you waste 15 minutes re-contextualizing. With them, Claude knows your stack, conventions, commands, and gotchas from the first message — and safety hooks stop it from editing `main` or running `rm -rf /` before you notice.

Writing all of this from scratch takes hours and you'll miss things (branch guards, stdin-parsing hooks, skill frontmatter quirks). This template is the shortcut: a minimal, honest baseline you can read in 10 minutes, install in 2, and prune down to what your project actually uses.

Based on notes from reviewing notable open-source Claude Code configurations (Supabase, Bitwarden, Vercel, Anthropic, Cloudflare, OpenAI, and others). Contributor context for working on this repo lives in [`docs/MAINTAINERS.md`](./docs/MAINTAINERS.md).

## What this changes vs bare Claude Code

Without this template, Claude Code starts every session with zero project context. Here's what's different:

| Without template | With template |
|-----------------|---------------|
| Claude asks "what's your stack?" every session | Stack, conventions, and commands loaded automatically |
| No branch protection — Claude can edit `main` | Hook blocks edits on `main`/`master` automatically |
| No safety net for destructive commands | Bash safety hook blocks `rm -rf /`, `git push --force`, etc. |
| Claude forgets your conventions between sessions | Skills enforce patterns (naming, architecture, error handling) |
| No dynamic context | SessionStart hook shows branch, last commit, uncommitted changes |
| UserPromptSubmit rarely used | Ships an opt-in example hook (`user-prompt-context.sh`) for injecting task context at every prompt |
| You re-explain the deploy workflow each time | `/deploy` command available instantly |

Setup takes 2 minutes. See [Installation](#installation).

## What you get

- **Universal core skills** — `coding-principles`, `debugging`, `error-handling`, `testing`, `git-workflow`, `code-review` — stack-agnostic and loaded on trigger.
- **Safety hooks** — branch guard blocks `main`/`master` edits, `dangerous-rm-guard.sh` blocks destructive commands, `lint-on-edit.sh` auto-formats JS/TS/Python/Go/Rust after every edit, `session-start.sh` injects git context.
- **One-command install** — `npx create-claude-code-config` copies only the files you need; stack-specific skills (`.claude/skills/stacks/`) are opt-in.

## Installation

### Option A: CLI (recommended)

```bash
npx create-claude-code-config
```

Prompts for your project directory and stack. Copies only the files you need.

### Option B: Manual

```bash
git clone https://github.com/felixhennequin-gif/claude-code-config-template.git /tmp/ai-template
cd /tmp/ai-template

cp template/CLAUDE.md your-project/CLAUDE.md
cp template/CLAUDE.local.md.example your-project/CLAUDE.local.md
cp template/.claudeignore your-project/.claudeignore
cp -r .claude your-project/.claude

echo "CLAUDE.local.md" >> your-project/.gitignore
echo ".claude/settings.local.json" >> your-project/.gitignore
```

This gives you the stack-agnostic baseline: hooks, commands, rules, and the universal core skills (`coding-principles`, `debugging`, `error-handling`, `testing`, `git-workflow`, `code-review`).

> **Windows users:** the manual snippet above uses `cp` / `echo >>`, which work in Git Bash and WSL. In native PowerShell, replace `cp -r` with `Copy-Item -Recurse` and `echo "x" >> file` with `Add-Content file "x"`. The hooks in `.claude/hooks/` are bash scripts — they run under Git Bash, WSL, or Cygwin, not native PowerShell or cmd.exe. The `create-claude-code-config` CLI installs the files fine from PowerShell, but the hooks themselves still need a bash runtime to execute.

> The hook in `settings.json` blocks edits on `main` and `master`. If your project uses a different protected branch, update the branch name in `.claude/settings.json`. To bypass temporarily (solo repos, docs-only commits), export `ALLOW_MAIN_EDIT=true` before launching Claude Code — the guard short-circuits when that variable is set.

> `settings.json` ships with a stack-agnostic `permissions.allow` list (`Read`, `Grep`, `Glob`, plus an explicit list of safe `git` subcommands — `status`, `diff`, `log`, `show`, `add`, `commit`, `push`, `fetch`, `pull`, `branch`, `checkout`, `switch`, `stash`, `merge`, `rebase`, `tag`, `remote`, `restore`). Destructive git commands like `git reset --hard`, `git clean -fd`, `git branch -D`, and `git checkout --` are **not** in the allowlist — run them manually if you really need them. Add entries for your own stack's commands — examples:
>
> ```jsonc
> // Node.js
> "Bash(npm:*)", "Bash(npx:*)"
>
> // Python
> "Bash(pytest:*)", "Bash(ruff:*)", "Bash(alembic:*)", "Bash(pip:*)"
>
> // Go
> "Bash(go:*)", "Bash(golangci-lint:*)"
>
> // Rust
> "Bash(cargo:*)"
> ```

### Add stack skills (optional)

> If you used the CLI, stacks were already selected during setup. This section is for manual installs.

The `.claude/skills/stacks/` directory ships with skills for a few common frameworks. Delete the whole folder if you don't use any of them, or remove just the ones you don't need:

```bash
# Drop everything stack-specific
rm -rf your-project/.claude/skills/stacks/

# Or keep only what you use — example for a non-React backend:
rm -rf your-project/.claude/skills/stacks/react-frontend
rm -rf your-project/.claude/skills/stacks/prisma-patterns  # if you don't use Prisma
```

Available stack skills:

| Skill | Triggers on |
|---|---|
| [`stacks/prisma-patterns`](./.claude/skills/stacks/prisma-patterns/SKILL.md) | Prisma 7 schema, migrations, queries, services |
| [`stacks/express-api`](./.claude/skills/stacks/express-api/SKILL.md) | Express 5 routes, controllers, middleware, validators |
| [`stacks/react-frontend`](./.claude/skills/stacks/react-frontend/SKILL.md) | React 19 + Vite + Tailwind v4 components, hooks, pages |
| [`stacks/symfony-api`](./.claude/skills/stacks/symfony-api/SKILL.md) | Symfony 5.4+ controllers, services, Doctrine entities, API Platform resources |
| [`stacks/ci-cd-pipeline`](./.claude/skills/stacks/ci-cd-pipeline/SKILL.md) | GitHub Actions + GitLab CI workflows, audits, debugging |

**Why these stacks?** The shipped list reflects what the maintainer has production experience with — not a claim that Express, React, Prisma, Symfony, and GitHub Actions are the "right" stack. The value of a skill comes from rules grounded in real use, so adding a stack speculatively would dilute quality. Missing your stack? Contributions for FastAPI, Django, Rails, NestJS, Rust (axum), Laravel, Phoenix, etc. are welcome — see [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the quality bar and [`CONTRIBUTING.md#adding-a-new-stack`](./CONTRIBUTING.md#adding-a-new-stack) for the checklist.

## What to delete

This template is a **starting point, not a minimum viable install**. Every file is cargo unless you actively use it. After installing, walk through the tree and delete anything that doesn't match your project. Here's the triage:

| Path | Delete if |
|---|---|
| `.claude/skills/stacks/*` | You don't use that stack (e.g. delete `react-frontend` on a pure backend). Stacks are opt-in — an unused skill still costs context budget. |
| `.claude/skills/core/*` | Almost never — these are stack-agnostic. The one exception: if your team already has a stricter internal standard that contradicts one, replace it rather than stack contradictions. |
| `.claude/commands/*` | You already have the workflow documented elsewhere (e.g. delete `/deploy` if your deploy lives in a runbook). |
| `.claude/hooks/user-prompt-context.sh` | You don't want per-prompt injection (it ships opt-in, unwired). |
| `.claude/hooks/notification.sh` | You don't want a desktop ping when Claude waits for input. |
| `.claude/agents/` | It's empty by default. See `examples/agents/` if you want stack-flavored subagents — copy only what applies. |
| `examples/` | Always, after reading them once. They're references for authoring new skills/agents/CLAUDE.md files, not runtime files. |
| `ROUTINES.md` + `examples/routines/` | You're not using cloud-based routines. These are a speculative preview. |

**Rule of thumb:** if you haven't touched a file in a month and can't explain what triggers it, delete it. You can always re-copy from this repo.

## Principles

1. **Max ~80 lines for the project CLAUDE.md.** Beyond that, Claude drops parts of it.
2. **Don't duplicate what a linter already does.** Use a hook instead.
3. **Point to docs, don't copy them.** `See TESTING.md` beats 50 lines on how to test.
4. **Build / test / lint commands are the minimum viable.**
5. **Skills are the best ROI.** A well-written skill gets reused automatically every time its trigger matches.
6. **Hooks are token-free.** Block main, auto-format — deterministic, no model involvement.
7. **Routines are for judgment; hooks are for rules.** Block `main` with a hook (deterministic). Review a PR with a routine (needs the model). Don't use a routine for something a hook handles.
8. **Know your token budget.** Every skill costs tokens — see [docs/CONTEXT-BUDGET.md](docs/CONTEXT-BUDGET.md).

See [docs/VALIDATION.md](docs/VALIDATION.md) for the validation template — fill it after testing on your own project.

### Routines (new — April 2026)

Cloud-based automations that run on Anthropic's infrastructure without your machine.
See [ROUTINES.md](ROUTINES.md) for the full guide and setup instructions.
Example prompts live under `examples/routines/` as a speculative preview —
the CLI does not copy them into your project. Copy the prompt into
[claude.ai/code/routines](https://claude.ai/code/routines), adapt it, and
configure your trigger.

## What's in this template

```
.
├── cli/                                   # npx create-claude-code-config (scaffolding CLI)
│   ├── package.json
│   ├── bin/
│   ├── src/
│   └── template-files/                    # Embedded copy of template files
├── template/
│   ├── CLAUDE.md                          # Downstream project context (copy this)
│   ├── CLAUDE.local.md.example            # Personal overrides template
│   └── .claudeignore                      # Ignore list (node_modules, dist, lockfiles, …)
├── .claude/
│   ├── settings.json                      # Hooks + permissions (branch guard, dangerous-rm-guard, lint, notification)
│   ├── agents/
│   │   └── README.md                      # Empty by default — see examples/agents/
│   ├── commands/
│   │   ├── deploy.md                      # /deploy — deployment workflow
│   │   └── audit.md                       # /audit — full quality audit
│   ├── skills/
│   │   ├── core/
│   │   │   ├── coding-principles/SKILL.md # Universal behavioral rules
│   │   │   ├── debugging/SKILL.md         # Structured debugging workflow
│   │   │   ├── error-handling/SKILL.md    # Universal error-handling patterns
│   │   │   ├── testing/SKILL.md           # Testing strategy and decisions
│   │   │   ├── git-workflow/SKILL.md      # Branches, commits, PRs, rebasing
│   │   │   └── code-review/SKILL.md       # Triage external reviews → roadmap → execute
│   │   └── stacks/                        # Optional — delete what you don't use
│   │       ├── prisma-patterns/SKILL.md   # Prisma 7 conventions
│   │       ├── express-api/SKILL.md       # Express 5 patterns
│   │       ├── react-frontend/SKILL.md    # React 19 + Tailwind v4
│   │       └── ci-cd-pipeline/SKILL.md    # GitHub Actions + GitLab CI (delete if on Jenkins/Drone/etc.)
│   ├── hooks/
│   │   ├── lint-on-edit.sh                # Auto-lint after every edit (JS/TS/Python/Go/Rust)
│   │   ├── session-start.sh               # Injects git context at session start
│   │   ├── dangerous-rm-guard.sh          # Blocks a small list of classically dangerous shell commands
│   │   ├── notification.sh                # Desktop alert when Claude waits for input
│   │   └── user-prompt-context.sh         # UserPromptSubmit example (not wired — see file)
│   └── rules/
│       └── banned-patterns.md             # Universal + JS/TS + Python anti-patterns (path-scoped)
├── ROUTINES.md                       # Guide to cloud-based routines (speculative preview)
├── docs/
│   ├── MAINTAINERS.md                     # Contributor guide for working on this repo
│   ├── HACKING.md                         # Smoke tests and CLI notes
│   ├── CONTEXT-BUDGET.md                  # Token estimates and budget profiles
│   └── VALIDATION.md                      # Real-world test results (template)
├── examples/
│   ├── agents/
│   │   ├── reviewer.md                    # Example: Node.js code reviewer
│   │   └── security-auditor.md            # Example: Node.js security auditor
│   ├── routines/                          # Speculative preview — not copied by the CLI
│   │   ├── pr-review.md                   # Automated PR code review
│   │   ├── dependency-audit.md            # Weekly dep check + security audit
│   │   ├── deploy-verify.md               # Post-deploy smoke tests
│   │   ├── bug-triage.md                  # Nightly pick-and-fix top bug
│   │   └── docs-drift.md                  # Weekly stale docs detection
│   ├── express-api.CLAUDE.md
│   ├── nextjs-fullstack.CLAUDE.md
│   ├── fastapi-backend.CLAUDE.md
│   └── go-api.CLAUDE.md
├── .github/                               # Issue/PR templates, CI workflow
├── CONTRIBUTING.md
├── CHANGELOG.md
└── README.md
```

## Global config and settings composition

Create `~/.claude/CLAUDE.md` for cross-project preferences:

```markdown
# Global preferences
- Always run tests before commit
- Prefer simplicity — no over-engineering
- Conventional commits required
- No console.log in production
```

Keep it under 15 lines. Anything project-specific belongs in the project's own `CLAUDE.md`.

**`.claude/settings.local.json`** is gitignored and ships as an empty permissions override. Use it to add personal tool permissions without touching the shared `settings.json`:

```json
{
  "permissions": {
    "allow": ["Bash(python:*)", "Bash(pytest:*)"]
  }
}
```

**Settings precedence** — Claude Code loads in this order:

1. `~/.claude/settings.json` — user-level global (your personal permissions baseline)
2. `.claude/settings.json` — project-level (committed to the repo)
3. `.claude/settings.local.json` — project-level personal overrides (gitignored)

Later entries override earlier ones. A permission in `settings.local.json` wins over the same entry in `.claude/settings.json`. Note: if you add `Bash(npm:*)` to `~/.claude/settings.json` but your project's `.claude/settings.json` doesn't list it, the permission is still granted — global settings apply.

### MCP integration

This template does not ship a `.mcp.json` — MCP server configs are project-specific. Create one at your project root:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"]
    }
  }
}
```

See [Anthropic MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp) for available servers and configuration.

## Credits

Research based on analysis of: Supabase (supabase-js), Bitwarden (server, android, ai-plugins), Vercel (next-devtools-mcp, agent-skills), Anthropic (claude-code-action), Cloudflare (6 official skills), OpenAI (openai-agents-python), and other notable community templates.

## Compared to alternatives

This template is an **opinionated starter kit** — not a framework, not a guide, not a marketplace.

| Project | Approach | When to use it instead |
|---------|----------|----------------------|
| [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) | Comprehensive showcase with Actions, scheduled hooks | You want a batteries-included demo with more workflows |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | CLI marketplace with 600+ components | You want to pick individual agents/commands from a catalog |
| [midudev/autoskills](https://github.com/midudev/autoskills) | Auto-generates skills from your codebase using AI | You want skills generated automatically from your actual code rather than written manually |
| [serpro69/claude-toolbox](https://github.com/serpro69/claude-toolbox) | Plugin framework with sync infrastructure | You want a managed upgrade path across projects |
| [abhishekray07/claude-md-templates](https://github.com/abhishekray07/claude-md-templates) | Teaching resource with before/after examples | You're learning Claude Code and want to understand the "why" |

**This template** is for developers who want a clean starting point they can understand in 5 minutes, customize for their stack, and own completely. Use the CLI to scaffold in 30 seconds, or copy files manually — either way, there are no runtime dependencies and nothing to update.

## Contributing

Contributions are welcome — new skills, rules, hooks, or fixes to existing ones. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the workflow, file conventions, and how to test changes with Claude Code.

Questions, bug reports, and ideas belong in [GitHub Issues](https://github.com/felixhennequin-gif/claude-code-config-template/issues). Open-ended discussions go in [Discussions](https://github.com/felixhennequin-gif/claude-code-config-template/discussions).

## License

MIT
