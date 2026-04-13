# Contributing

Thanks for wanting to improve `claude-code-config-template`. This repo is a template for
wiring Claude Code into a project — every file here ends up in real developers'
`.claude/` directories, so the quality bar is higher than a usual README.

## What we accept

- **New skills** (`.claude/skills/<name>/SKILL.md`) for stacks we don't cover yet:
  Django, FastAPI, Go (chi/gin/echo), Rust (axum/actix), Rails, Laravel, Spring,
  Elixir/Phoenix, Next.js App Router, SvelteKit, Astro, etc.
- **New agents** (`.claude/agents/*.md`) for focused use cases: perf auditor,
  migration planner, accessibility checker, i18n reviewer, etc.
- **New commands** (`.claude/commands/*.md`) that codify a repeatable workflow.
- **New examples** (`examples/*.CLAUDE.md`) — fully anonymized `CLAUDE.md` files
  showing the template adapted to a real project shape.
- **Improvements** to existing skills / agents / commands / hooks.
- **Bug fixes** in `settings.json` hook syntax, `lint-on-edit.sh`, or broken
  frontmatter.

## Fork, clone, branch

```bash
# Fork on GitHub, then:
git clone https://github.com/<your-username>/claude-code-config-template.git
cd claude-code-config-template
git checkout -b feat/skill-django
```

Branch naming:

- `feat/skill-<stack>` — new skill
- `feat/agent-<name>` — new agent
- `feat/command-<name>` — new command
- `feat/example-<project>` — new example
- `fix/hook-<what>` — hook or settings fix
- `docs/<area>` — docs-only change

## Commits

- **Conventional commits**: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`.
- **One logical change per commit.** Don't bundle a new skill with an unrelated
  settings.json tweak.
- Commit messages in English.

## Pull request

Open the PR against `master`. In the description, answer:

1. **What** — which file(s) did you add or change?
2. **Why** — what problem does it solve? What stack is it for?
3. **How to test** — drop this skill/agent/command into a project, describe
   the prompt you used, and paste the observed Claude Code behavior.

Every PR goes through `.github/PULL_REQUEST_TEMPLATE.md`. Check every box or
justify why it doesn't apply.

## Quality bar

This is the part that matters. Generic advice does not help Claude produce
better code — in fact, it dilutes the context window.

### Skills (`.claude/skills/<name>/SKILL.md`)

Every skill must:

- **Have a trigger-ready `description`** in the frontmatter. It should name the
  concrete situations that should activate it. Bad: "Helps with backend code."
  Good: "Django REST Framework conventions. Activates when working on
  `views.py`, `serializers.py`, `urls.py`, or DRF viewsets."
- **Show at least one GOOD vs BAD code example** per major rule.
- **List concrete anti-patterns** with the `❌` marker. Anti-patterns are the
  highest-ROI content in a skill — they stop Claude from repeating known
  mistakes.
- **Not duplicate the linter.** If ESLint/Ruff/gofmt already enforces it, don't
  mention it. The hook does that for free.
- **Stay under ~200 lines.** Beyond that, split into multiple skills.

### Agents (`.claude/agents/*.md`)

- Frontmatter with `name`, `description`, `tools`, `model`.
- `description` must make it obvious *when* Claude should invoke the agent.
  "Use when reviewing PRs, auditing code quality, or before merging" — not
  "Reviews code."
- Scope the `tools` list to the minimum needed. A reviewer agent does not need
  `Bash(rm:*)`.

### Commands (`.claude/commands/*.md`)

- Start with a one-line usage comment: `# Usage: /command-name [args]`.
- Every step must be concrete and executable. No "think about performance" —
  say which file to open and which pattern to grep for.
- Stop-on-first-failure semantics where it makes sense.

### Examples (`examples/*.CLAUDE.md`)

- Must be anonymized: no real IPs, domains, server hostnames, personal names,
  seed data, or unreleased business information.
- Must be under ~80 lines — examples are reference material, not
  documentation dumps, and Claude Code drops context beyond that.

## File structure requirements

### SKILL.md frontmatter

```yaml
---
name: skill-name
description: One sentence. Must include the triggers (file types, keywords, tasks).
allowed-tools: Read, Grep, Glob
---
```

### Agent frontmatter

```yaml
---
name: agent-name
description: When to invoke this agent. Be specific.
tools: Read, Grep, Glob
model: sonnet
---
```

## What NOT to submit

- ❌ Your personal `CLAUDE.local.md`
- ❌ A `settings.json` with hardcoded paths, IPs, or usernames
- ❌ Skills that only repeat what ESLint / Prettier / Ruff / `go vet` already
  catches
- ❌ "Best practices" essays. Rules, examples, and anti-patterns only.
- ❌ Examples pulled from closed-source projects without sanitization
- ❌ Binary files, screenshots, or generated artifacts

### Adding a new stack

To add support for a new framework/stack:

1. **Skill** — Create `.claude/skills/stacks/<name>/SKILL.md` with proper frontmatter (`name`, `description` that names concrete trigger situations). See any existing stack skill for the format.
2. **Example CLAUDE.md** — Create `examples/<name>.CLAUDE.md` showing a realistic project config for that stack. Include commands, conventions, structure, and gotchas.
3. **(Optional) Example agent** — If the stack has specific review/audit concerns, add an agent in `examples/agents/`.

The skill should be under 80 lines and focus on conventions Claude wouldn't know from its training data — things specific to the framework version, common mistakes, and patterns your team enforces.

## Questions

Open a GitHub Discussion or an issue with the `question` label before starting
a large contribution — it saves both of us time.
