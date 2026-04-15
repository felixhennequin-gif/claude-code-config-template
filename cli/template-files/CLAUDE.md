# [Project name]

[One-liner project description.]

## Stack

- **Language / runtime**: [e.g. Node.js 22, Python 3.12, Go 1.22, Rust stable]
- **Framework**: [e.g. Express, Django, Gin, Axum]
- **Database**: [e.g. PostgreSQL + Prisma, SQLite, MongoDB, none]
- **Frontend**: [e.g. React + Vite, HTMX, none]
- **Infra**: [process manager / container runtime / hosting target]

## Structure

```
[path]/     → [what lives here]
[path]/     → [what lives here]
[path]/     → [what lives here]
```

<!-- Keep this tree shallow. One line per top-level directory is enough. -->

## Commands

```bash
[cmd]         # Dev server / watcher
[cmd]         # Tests
[cmd]         # Lint / format
[cmd]         # Production build
[cmd]         # Database migrations (if any)
```

## Conventions

- [Commit style — e.g. Conventional Commits: feat:, fix:, chore:, docs:]
- [Comments / docstrings policy]
- [Layering — e.g. thin controllers, logic in services]
- [Validation / schema library if any]
- [Logging policy — no print/console.log in production code]
- [Anything else a new contributor would get wrong by default]

## Git workflow

- [Main branch name and its role — e.g. `main` = production, protected]
- [Integration branch if any]
- [Feature branch naming — e.g. `feat/xxx`, `fix/xxx`]
- [PR requirements — reviews, required checks]

## Automation

- **Hooks** (`.claude/hooks/`) — deterministic guards: branch guard, lint-on-edit, dangerous-command guard, session context.
- **Agents** (`.claude/agents/`) — stack-specific subagents; empty by default, see `examples/agents/`.
- **CI/CD** — see `.claude/skills/stacks/ci-cd-pipeline/SKILL.md` for patterns (build once / deploy many, SHA-pinned actions, scoped secrets).

## Gotchas

- Environment variables are not copied by deploy scripts — verify `.env` matches the target
- Database seeds assume an empty database — running on existing data may cause constraint errors
<!-- Add project-specific gotchas below -->

## Off-limits

<!-- List files and directories Claude should never modify -->
- `[generated files — e.g. prisma/migrations/, dist/, __pycache__/]` — do not edit or delete
- `[vendor/ or node_modules/]` — never touch
- `[any already-applied migration files]` — migrations are append-only

## References

- See `CONTRIBUTING.md` for the contribution workflow
- See `.claude/skills/` for stack-specific conventions loaded per task
- [Link to the data model / API spec / architecture doc if any]
