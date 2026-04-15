# Agents

This directory ships with one stack-agnostic default agent:

- **`reviewer.md`** — a code reviewer that checks banned patterns, security, error handling, tests, and convention drift **without** assuming a specific framework. Safe to leave installed in any project; it reads `.claude/rules/banned-patterns.md`, `CLAUDE.md`, and any stack skills present to calibrate itself.

Stack-flavored example agents (Node/Prisma reviewer, Node security auditor, etc.) live under [`examples/agents/`](../../examples/agents/) in the repo. They encode assumptions about a specific stack — copy the content, edit the system prompt to match your project, and drop the file into this directory to activate it.

Agent frontmatter reference:

- `name` — slug used when invoking the agent
- `description` — tells Claude Code *when* to use it; be specific
- `model` — `sonnet`, `haiku`, `opus`, etc.
- `tools` *(optional)* — restrict the agent to a tool subset (e.g. `Read, Grep, Glob` for a read-only reviewer). Omit to inherit from `.claude/settings.json`.
