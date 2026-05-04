# Agents

This directory ships with stack-agnostic default agents:

- **`reviewer.md`** — code reviewer that checks banned patterns, security, error handling, tests, and convention drift **without** assuming a specific framework. Safe to leave installed in any project; it reads `.claude/rules/banned-patterns.md`, `CLAUDE.md`, and any stack skills present to calibrate itself.
- **`architect.md`** — architecture-shape reviewer (layering, separation of concerns, dependency direction). Companion to `reviewer.md`; their checklists are intentionally non-overlapping.
- **`pr-creator.md` / `commit-writer.md` / `changelog-updater.md`** — Haiku-tier workers for the mechanical PR / commit / changelog flow. Designed to be orchestrated by `/pr` rather than invoked directly. See `.claude/commands/pr.md` for the canonical orchestration pattern.

Stack-flavored example agents (Node/Prisma reviewer, Node security auditor, FastAPI reviewer, etc.) live under [`examples/agents/`](https://github.com/felixhennequin-gif/claude-code-config-template/tree/master/examples/agents/) in the repo. They encode assumptions about a specific stack — copy the content, edit the system prompt to match your project, and drop the file into this directory to activate it.

Agent frontmatter reference:

- `name` — slug used when invoking the agent
- `description` — tells Claude Code *when* to use it; be specific
- `model` — `sonnet`, `haiku`, `opus`, etc.
- `tools` *(optional)* — restrict the agent to a tool subset (e.g. `Read, Grep, Glob` for a read-only reviewer). Omit to inherit from `.claude/settings.json`.
