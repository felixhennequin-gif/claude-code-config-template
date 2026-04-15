# Contributing

Thanks for wanting to improve `claude-code-config-template`. This repo is a template for
wiring Claude Code into a project — every file here ends up in real developers'
`.claude/` directories, so the quality bar is higher than a usual README.

## What we accept

- **New skills** (`.claude/skills/stacks/<name>/SKILL.md`) for stacks we don't cover yet:
  Django, FastAPI, Go (chi/gin/echo), Rust (axum/actix), Rails, Laravel, Spring,
  Elixir/Phoenix, Next.js App Router, SvelteKit, Astro, etc.
- **New agents** (`.claude/agents/*.md`) for focused use cases: perf auditor,
  migration planner, accessibility checker, i18n reviewer, etc.
- **MCP-connected agents** — agents that depend on an MCP server (Sentry,
  Linear, GitHub, Datadog, etc.) for their core behavior. Put them under
  `examples/agents/` with a header comment listing the exact MCP server
  config required, and list the tool (e.g. `mcp__sentry`) in the frontmatter
  `tools:` field. If the MCP tool is not available at runtime, the agent
  must stop and say so — never fall back to scraping or fabricating data.
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

**Before submitting**: run `make check` locally. It runs the same checks CI
runs, plus the hook smoke tests, so you can catch registry drift, broken
frontmatter, or template-sync issues before they hit the pipeline.

Every PR goes through `.github/PULL_REQUEST_TEMPLATE.md`. Check every box or
justify why it doesn't apply.

## Quality bar

This is the part that matters. Generic advice does not help Claude produce
better code — in fact, it dilutes the context window.

### Skills (`.claude/skills/core/<name>/SKILL.md` or `.claude/skills/stacks/<name>/SKILL.md`)

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

- Frontmatter with `name`, `description`, `model` (required) and `tools` (optional).
- `description` must make it obvious *when* Claude should invoke the agent.
  "Use when reviewing PRs, auditing code quality, or before merging" — not
  "Reviews code."
- `tools` is **optional**. Include it to restrict the agent to a specific tool
  subset — useful for read-only agents like `reviewer` or `security-auditor`.
  Omit it to inherit project permissions from `.claude/settings.json`.
  When you do include it, scope the list to the minimum needed: a reviewer
  agent never needs `Bash(rm:*)`. Never use `Bash(*)` as a wildcard — that
  defeats the purpose of scoping.

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
---
```

The `allowed-tools` field is optional. Omit it for behavioral skills that guide
how Claude writes code. Include it only for skills that should restrict Claude
to specific tools (e.g., a read-only analysis skill).

### Agent frontmatter

```yaml
---
name: agent-name
description: When to invoke this agent. Be specific.
model: sonnet
# tools is optional — include it only to restrict this agent to a tool subset.
# tools: Read, Grep, Glob
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

## Skill maintenance policy

Skills age. A skill written against Prisma 7 becomes misleading the week Prisma 8 drops; the `typedSql` preview flag may graduate, rename, or be removed. Without a maintenance story, the template quietly accumulates stale advice and everyone who copied it inherits it.

- **Ownership.** Every skill under `.claude/skills/` has an implicit owner — the person who last touched it. If you're editing a skill, you become the new owner. There is no separate registry; `git log --follow` is the source of truth.
- **Cadence.** Each stack skill must be re-verified **per major version of its underlying framework/library OR every 90 days, whichever comes first** (Prisma 7 → 8, React 19 → 20, Symfony 5.4 → 6.x, etc.). The 90-day floor catches skills whose framework hasn't bumped a major but whose "latest" recommendations, preview flags, or deprecations have moved anyway. Core skills (`coding-principles`, `debugging`, etc.) are version-agnostic and only need a pass when the underlying language semantics change.
- **`last-verified` frontmatter field.** Every `.claude/skills/stacks/*/SKILL.md` carries a top-level `last-verified: YYYY-MM-DD` in its YAML frontmatter. Bump it each time you audit the skill against upstream docs — even if no content changed. `scripts/check-skill-freshness.py` (wired into `make lint` and `.github/workflows/lint.yml`) emits a GitHub Actions `::warning::` annotation when the field is missing or older than 90 days. The check is advisory, not blocking — a warning is the signal to re-audit, not to rubber-stamp the date.
- **Inline `last verified` notes.** Any section that cites a feature flag, preview API, deprecated option, or "latest" recommendation should also carry an inline `last verified YYYY-MM-DD` line so a reader skimming the body can tell which specific claim has aged out (the frontmatter field covers the file as a whole). See `prisma-patterns/SKILL.md` (`typedSql`) for the shape.
- **Reporting stale skills.** If you hit a skill that gives wrong advice for the current framework version, open a GitHub Issue titled `skill: <name> outdated for <framework> <version>`. Include the specific line(s) that broke. A stale skill is a bug, not a documentation task — it goes through the normal fix workflow.
- **Pruning unowned skills.** If a stack skill has had no maintenance commits in 18 months *and* the latest framework version is ≥ 2 majors ahead of what the skill cites, it's a candidate for removal rather than rewrite. Open an issue first; don't silently delete.
- **CI enforces the quality bar.** `.github/workflows/lint.yml` refuses any skill without an `## Anti-patterns` section and any markdown file with broken internal links. If CI fails, fix the skill — don't loosen the check.

## Questions

Open a GitHub Discussion or an issue with the `question` label before starting
a large contribution — it saves both of us time.
