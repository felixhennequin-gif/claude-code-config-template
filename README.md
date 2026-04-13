# claude-code-config-template

![License](https://img.shields.io/github/license/felixhennequin-gif/claude-code-config-template) ![CI](https://img.shields.io/github/actions/workflow/status/felixhennequin-gif/claude-code-config-template/lint.yml?label=lint) ![GitHub stars](https://img.shields.io/github/stars/felixhennequin-gif/claude-code-config-template?style=social)

Opinionated starter template for Claude Code — agents, skills, hooks, and commands for any project.

Core files (CLAUDE.md, hooks, commands, the `coding-principles` skill) are stack-agnostic and ship with every install. Stack-specific conventions live under `.claude/skills/stacks/` and can be kept, pruned, or replaced individually.

Based on analysis of ~55 open-source repos (Supabase, Bitwarden, Vercel, Anthropic, Cloudflare, OpenAI) — see [the full research](./RESEARCH.md).

## Why

Claude Code automatically loads `CLAUDE.md` and `.claude/` at the start of every session. Without them, you waste 15 minutes re-contextualizing. With them, Claude knows your stack, conventions, commands, and gotchas from the first message.

> The root `CLAUDE.md` in this repo describes the template project itself — it's what Claude Code reads when working *on* this template. The blank file you copy into *your* project lives at [`template/CLAUDE.md`](./template/CLAUDE.md).

## What this changes vs bare Claude Code

Without this template, Claude Code starts every session with zero project context. Here's what's different:

| Without template | With template |
|-----------------|---------------|
| Claude asks "what's your stack?" every session | Stack, conventions, and commands loaded automatically |
| No branch protection — Claude can edit `main` | Hook blocks edits on `main`/`master` automatically |
| No safety net for destructive commands | Bash safety hook blocks `rm -rf /`, `git push --force`, etc. |
| Claude forgets your conventions between sessions | Skills enforce patterns (naming, architecture, error handling) |
| No dynamic context | SessionStart hook shows branch, last commit, uncommitted changes |
| You re-explain testing/deploy workflow each time | `/test` and `/deploy` commands available instantly |

Setup takes 2 minutes. See [Installation](#installation).

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
cp -r .claude your-project/.claude

echo "CLAUDE.local.md" >> your-project/.gitignore
echo ".claude/settings.local.json" >> your-project/.gitignore
```

This gives you the stack-agnostic baseline: hooks, commands, rules, and the universal `coding-principles` skill.

> The hook in `settings.json` blocks edits on `main` and `master`. If your project uses a different protected branch, update the branch name in `.claude/settings.json`.

> `settings.json` ships with a stack-agnostic `permissions.allow` list (`Read`, `Grep`, `Glob`, `Bash(git:*)`). Add entries for your own stack's commands — examples:
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
| [`stacks/fastapi-backend`](./.claude/skills/stacks/fastapi-backend/SKILL.md) | FastAPI + SQLAlchemy + Alembic routes, models, services |

Missing your stack? Contributions for Django, Rails, Rust (axum), Laravel, Phoenix, etc. are welcome — see [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Principles

1. **Max ~80 lines for the project CLAUDE.md.** Beyond that, Claude drops parts of it.
2. **Don't duplicate what a linter already does.** Use a hook instead.
3. **Point to docs, don't copy them.** `See TESTING.md` beats 50 lines on how to test.
4. **Build / test / lint commands are the minimum viable.**
5. **Skills are the best ROI.** A well-written skill gets reused automatically every time its trigger matches.
6. **Hooks are token-free.** Block main, auto-format — deterministic, no model involvement.
7. **Know your token budget.** Every skill costs tokens — see [docs/CONTEXT-BUDGET.md](docs/CONTEXT-BUDGET.md).

## What's in this template

```
.
├── CLAUDE.md                              # Context for working on this repo itself
├── cli/                                   # npx create-claude-code-config (scaffolding CLI)
│   ├── package.json
│   ├── bin/
│   ├── src/
│   └── template-files/                    # Embedded copy of template files
├── template/
│   ├── CLAUDE.md                          # Downstream project context (copy this)
│   └── CLAUDE.local.md.example            # Personal overrides template
├── .claude/
│   ├── settings.json                      # Hooks config (branch guard, lint, session-start, bash-safety)
│   ├── agents/
│   │   └── README.md                      # Empty by default — see examples/agents/
│   ├── commands/
│   │   ├── deploy.md                      # /deploy — deployment workflow
│   │   ├── audit.md                       # /audit — full quality audit
│   │   └── test.md                        # /test — run tests + coverage
│   ├── skills/
│   │   ├── core/
│   │   │   └── coding-principles/SKILL.md # Universal behavioral rules
│   │   └── stacks/                        # Optional — delete what you don't use
│   │       ├── prisma-patterns/SKILL.md   # Prisma 7 conventions
│   │       ├── express-api/SKILL.md       # Express 5 patterns
│   │       ├── react-frontend/SKILL.md    # React 19 + Tailwind v4
│   │       └── fastapi-backend/SKILL.md   # FastAPI + SQLAlchemy 2.x + Alembic
│   ├── hooks/
│   │   ├── lint-on-edit.sh                # Auto-lint after every edit
│   │   ├── session-start.sh               # Injects git context at session start
│   │   └── bash-safety.sh                 # Blocks dangerous shell commands
│   └── rules/
│       ├── test-files.md                  # Rules specific to test files
│       └── banned-patterns.md             # Universal + JS/TS + Python anti-patterns
├── docs/
│   └── CONTEXT-BUDGET.md                  # Token estimates and budget profiles
├── examples/
│   ├── agents/
│   │   ├── reviewer.md                    # Example: Node.js code reviewer
│   │   └── security-auditor.md            # Example: Node.js security auditor
│   ├── express-api.CLAUDE.md
│   ├── nextjs-fullstack.CLAUDE.md
│   ├── fastapi-backend.CLAUDE.md
│   └── go-api.CLAUDE.md
├── .github/                               # Issue/PR templates, CI workflow
├── CONTRIBUTING.md
├── CHANGELOG.md
├── RESEARCH.md
└── README.md
```

## Optional: global config

Create `~/.claude/CLAUDE.md` for cross-project preferences:

```markdown
# Global preferences
- Always run tests before commit
- Prefer simplicity — no over-engineering
- Conventional commits required
- No console.log in production
```

Keep it under 15 lines. Anything project-specific belongs in the project's own `CLAUDE.md`.

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

Research based on analysis of: Supabase (supabase-js), Bitwarden (server, android, ai-plugins), Vercel (next-devtools-mcp, agent-skills), Anthropic (claude-code-action), Cloudflare (6 official skills), OpenAI (openai-agents-python), and ~45 other open-source projects.

## Compared to alternatives

This template is an **opinionated starter kit** — not a framework, not a guide, not a marketplace.

| Project | Approach | When to use it instead |
|---------|----------|----------------------|
| [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) | Comprehensive showcase with Actions, scheduled hooks | You want a batteries-included demo with more workflows |
| [davila7/claude-code-templates](https://github.com/davila7/claude-code-templates) | CLI marketplace with 600+ components | You want to pick individual agents/commands from a catalog |
| [serpro69/claude-toolbox](https://github.com/serpro69/claude-toolbox) | Plugin framework with sync infrastructure | You want a managed upgrade path across projects |
| [abhishekray07/claude-md-templates](https://github.com/abhishekray07/claude-md-templates) | Teaching resource with before/after examples | You're learning Claude Code and want to understand the "why" |

**This template** is for developers who want a clean starting point they can understand in 5 minutes, customize for their stack, and own completely. No dependencies, no CLI, no lock-in.

## Contributing

Contributions are welcome — new skills, rules, hooks, or fixes to existing ones. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the workflow, file conventions, and how to test changes with Claude Code.

Questions, bug reports, and ideas belong in [GitHub Issues](https://github.com/felixhennequin-gif/claude-code-config-template/issues). Open-ended discussions go in [Discussions](https://github.com/felixhennequin-gif/claude-code-config-template/discussions).

## License

MIT
