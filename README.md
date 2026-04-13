# claude-code-config-template

![License](https://img.shields.io/github/license/felixhennequin-gif/claude-code-config-template) ![CI](https://img.shields.io/github/actions/workflow/status/felixhennequin-gif/claude-code-config-template/lint.yml?label=lint) ![GitHub stars](https://img.shields.io/github/stars/felixhennequin-gif/claude-code-config-template?style=social)

Opinionated starter template for Claude Code — agents, skills, hooks, and commands for any project.

Core files (CLAUDE.md, hooks, commands, the `coding-principles` skill) are stack-agnostic and ship with every install. Stack-specific conventions live under `.claude/skills/stacks/` and can be kept, pruned, or replaced individually.

Based on analysis of ~55 open-source repos (Supabase, Bitwarden, Vercel, Anthropic, Cloudflare, OpenAI) — see [the full research](./RESEARCH.md).

## Why

Claude Code automatically loads `CLAUDE.md` and `.claude/` at the start of every session. Without them, you waste 15 minutes re-contextualizing. With them, Claude knows your stack, conventions, commands, and gotchas from the first message.

> The root `CLAUDE.md` in this repo describes the template project itself — it's what Claude Code reads when working *on* this template. The blank file you copy into *your* project lives at [`template/CLAUDE.md`](./template/CLAUDE.md).

## Installation

### Quick start — core (always)

```bash
# Clone this template somewhere
git clone <this-repo-url> /tmp/ai-template
cd /tmp/ai-template

# Copy the core files into your project
cp template/CLAUDE.md your-project/CLAUDE.md
cp template/CLAUDE.local.md.example your-project/CLAUDE.local.md
cp -r .claude your-project/.claude

# Ignore personal files (if not already in your .gitignore)
echo "CLAUDE.local.md" >> your-project/.gitignore
echo ".claude/settings.local.json" >> your-project/.gitignore

# Edit CLAUDE.md with your project info
```

This gives you the stack-agnostic baseline: hooks, commands, rules, and the universal `coding-principles` skill.

> The hook in `settings.json` blocks edits on `main` and `master`. If your project uses a different protected branch, update the branch name in `.claude/settings.json`.

### Add stack skills (optional)

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

Missing your stack? Contributions for Django, FastAPI, Rails, Go (chi/gin), Rust (axum), Laravel, Phoenix, etc. are welcome — see [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Principles

1. **Max ~80 lines for the project CLAUDE.md.** Beyond that, Claude drops parts of it.
2. **Don't duplicate what a linter already does.** Use a hook instead.
3. **Point to docs, don't copy them.** `See TESTING.md` beats 50 lines on how to test.
4. **Build / test / lint commands are the minimum viable.**
5. **Skills are the best ROI.** A well-written skill gets reused automatically every time its trigger matches.
6. **Hooks are token-free.** Block main, auto-format — deterministic, no model involvement.

## What's in this template

```
.
├── CLAUDE.md                         # Context for working on this repo itself
├── template/
│   ├── CLAUDE.md                     # Downstream-facing project context (copy this into your project)
│   └── CLAUDE.local.md.example       # Template for personal overrides (copy to your project as CLAUDE.local.md)
├── .claude/
│   ├── settings.json                 # Deterministic hooks (block main/master, auto-lint, bash safety, session-start)
│   ├── agents/                       # Empty by default — see examples/agents/
│   ├── commands/
│   │   ├── deploy.md                 # /deploy — deployment workflow
│   │   ├── audit.md                  # /audit — full quality audit
│   │   └── test.md                   # /test — run tests + coverage
│   ├── skills/
│   │   ├── core/
│   │   │   └── coding-principles/SKILL.md  # Universal behavioral rules (think, simplify, surgical, goal-driven)
│   │   └── stacks/                         # Optional — keep only the ones you use
│   │       ├── prisma-patterns/SKILL.md    # Prisma 7 conventions
│   │       ├── express-api/SKILL.md        # Express 5 patterns
│   │       └── react-frontend/SKILL.md     # React 19 + Tailwind v4 patterns
│   ├── hooks/
│   │   ├── lint-on-edit.sh           # Auto-lint after every edit
│   │   ├── session-start.sh          # Inject dynamic git context at session start
│   │   └── bash-safety.sh            # Block destructive bash commands
│   └── rules/
│       └── test-files.md             # Rules specific to test files
├── examples/                         # Ready-to-adapt CLAUDE.md files + example agents
│   ├── express-api.CLAUDE.md
│   ├── nextjs-fullstack.CLAUDE.md
│   └── agents/                       # Example subagents (Node-specific — copy into .claude/agents/)
├── .github/                          # Issue / PR templates, funding, workflows
├── CONTRIBUTING.md                   # How to contribute a skill, rule, or hook
├── CODE_OF_CONDUCT.md                # Contributor Covenant v2.1
├── SECURITY.md                       # How to report a vulnerability
├── CHANGELOG.md                      # Release history
└── RESEARCH.md                       # Raw research data
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

## Contributing

Contributions are welcome — new skills, rules, hooks, or fixes to existing ones. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the workflow, file conventions, and how to test changes with Claude Code.

Questions, bug reports, and ideas belong in [GitHub Issues](https://github.com/felixhennequin-gif/claude-code-config-template/issues). Open-ended discussions go in [Discussions](https://github.com/felixhennequin-gif/claude-code-config-template/discussions).

## License

MIT
