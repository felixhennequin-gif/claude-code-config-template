# Example agents

These agents are written for a **Node.js / React / PostgreSQL** stack. They are examples, not defaults.

## Usage

Copy the agents you need into your project's `.claude/agents/` directory and edit the system prompt to match your stack:

```bash
cp examples/agents/reviewer.md your-project/.claude/agents/
cp examples/agents/security-auditor.md your-project/.claude/agents/
```

## Available examples

| Agent | Purpose |
|---|---|
| `reviewer.md` | Automated code review with Node.js-specific checklist |
| `security-auditor.md` | Security audit with P0/P1/P2 severity classification |
| `fastapi-reviewer.md` | Python/FastAPI-flavored reviewer |
| `sentry-triage.md` | Pulls recent Sentry errors via MCP, ranks by impact, proposes fixes. **Requires a Sentry MCP connector** (see header comment in the file) |

## Writing your own

An agent needs YAML frontmatter with `name`, `description`, and `model`. The body is the system prompt.

### `tools` is optional

`.claude/settings.json` sets the permission ceiling for every invocation. Agents inherit that ceiling by default. The frontmatter `tools:` field is a **narrowing mechanism**: include it to restrict an agent to a tool subset, omit it to inherit everything in `settings.json`.

```yaml
# Narrowed — good for read-only reviewers
---
name: reviewer
description: Reviews PRs before merge
model: sonnet
tools: Read, Grep, Glob
---
```

```yaml
# Inherits from settings.json — good for general-purpose agents
---
name: migration-planner
description: Plans multi-step refactors
model: sonnet
---
```

The example agents in this directory omit `tools:` — they inherit permissions from the project's `.claude/settings.json`. Add a `tools:` line yourself if you want to lock an agent to a read-only subset.

Never use `tools: Bash(*)` — it defeats the purpose of scoping. Prefer listing the specific bash commands the agent actually needs.

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for the full spec.
