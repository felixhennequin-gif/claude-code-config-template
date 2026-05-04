# Example agents

Two flavors live here:

- **Stack-flavored reviewers** — written for a specific stack. Copy and edit the system prompt to match your project.
- **Stack-agnostic workers** — mechanical Haiku-tier agents for commits, PRs, and changelog updates. Copy as-is.

## Usage

```bash
# Stack-flavored — edit after copying
cp examples/agents/reviewer.md your-project/.claude/agents/
cp examples/agents/security-auditor.md your-project/.claude/agents/

# Stack-agnostic — copy as-is
cp examples/agents/pr-creator.md your-project/.claude/agents/
cp examples/agents/commit-writer.md your-project/.claude/agents/
cp examples/agents/changelog-updater.md your-project/.claude/agents/
```

## Available examples

### Stack-flavored (Node.js / React / PostgreSQL — edit before use)

| Agent | Purpose | Model |
|---|---|---|
| `reviewer.md` | Automated code review with Node.js-specific checklist | sonnet |
| `security-auditor.md` | Security audit with P0/P1/P2 severity classification | sonnet |
| `fastapi-reviewer.md` | Code review for Python/FastAPI projects | sonnet |

### Stack-agnostic workers (copy as-is)

| Agent | Purpose | Model |
|---|---|---|
| `pr-creator.md` | Drafts PR title + body and runs `gh pr create` | haiku |
| `commit-writer.md` | Reads staged files, drafts a Conventional Commits message, commits | haiku |
| `changelog-updater.md` | Parses commits since last tag, appends `[Unreleased]` entries to `CHANGELOG.md` | haiku |

These three are designed to be invoked by the `/pr` slash command (or directly via the Task tool). The reasoning model orchestrates; the worker does the grunt work. See `.claude/commands/pr.md` for the canonical orchestration pattern.

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
