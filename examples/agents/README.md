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

## Writing your own

An agent needs YAML frontmatter with `name`, `description`, `tools`, and `model`. The body is the system prompt.

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for the full spec.
