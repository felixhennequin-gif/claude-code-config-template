# ai-config-template

AI architecture template for Node.js / React / PostgreSQL projects.

Based on analysis of ~55 open-source repos (Supabase, Bitwarden, Vercel, Anthropic, Cloudflare, OpenAI) — see [the full research](./RESEARCH.md).

## Why

Claude Code automatically loads `CLAUDE.md` and `.claude/` at the start of every session. Without them, you waste 15 minutes re-contextualizing. With them, Claude knows your stack, conventions, commands, and gotchas from the first message.

## What's in this template

```
.
├── CLAUDE.md                         # Project context (the only required file)
├── CLAUDE.local.md                   # Personal overrides (gitignored)
├── .claude/
│   ├── settings.json                 # Deterministic hooks (block main, auto-lint)
│   ├── settings.local.json           # Personal overrides (gitignored)
│   ├── agents/
│   │   ├── reviewer.md               # Automated code review
│   │   └── security-auditor.md       # Targeted security audit
│   ├── commands/
│   │   ├── deploy.md                 # /deploy — deployment workflow
│   │   ├── audit.md                  # /audit — full quality audit
│   │   └── test.md                   # /test — run tests + coverage
│   ├── skills/
│   │   ├── prisma-patterns/SKILL.md  # Prisma 7 conventions
│   │   ├── express-api/SKILL.md      # Express 5 patterns
│   │   └── react-frontend/SKILL.md   # React 19 + Tailwind v4 patterns
│   ├── hooks/
│   │   └── lint-on-edit.sh           # Auto-lint after every edit
│   └── rules/
│       └── test-files.md             # Rules specific to test files
└── RESEARCH.md                       # Raw research data
```

## Installation

```bash
# Clone this template somewhere
git clone <this-repo-url> /tmp/ai-template

# Copy into your project
cp /tmp/ai-template/CLAUDE.md your-project/CLAUDE.md
cp -r /tmp/ai-template/.claude your-project/.claude
cp /tmp/ai-template/CLAUDE.local.md your-project/CLAUDE.local.md

# Ignore personal files
echo "CLAUDE.local.md" >> your-project/.gitignore
echo ".claude/settings.local.json" >> your-project/.gitignore

# Edit CLAUDE.md with your project info
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

## Principles

1. **Max ~80 lines for the project CLAUDE.md.** Beyond that, Claude drops parts of it.
2. **Don't duplicate what a linter already does.** Use a hook instead.
3. **Point to docs, don't copy them.** `See TESTING.md` beats 50 lines on how to test.
4. **Build / test / lint commands are the minimum viable.**
5. **Skills are the best ROI.** A well-written Prisma skill gets reused automatically.
6. **Hooks are token-free.** Block main, auto-format — deterministic, no model involvement.

## Credits

Research based on analysis of: Supabase (supabase-js), Bitwarden (server, android, ai-plugins), Vercel (next-devtools-mcp, agent-skills), Anthropic (claude-code-action), Cloudflare (6 official skills), OpenAI (openai-agents-python), and ~45 other open-source projects.

## License

MIT
