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

## Gotchas

<!-- Project-specific pitfalls — the highest-value section. -->
<!-- Examples: -->
<!-- - Seed script requires an empty DB, otherwise unique constraint error -->
<!-- - `.env` is not copied by the deploy script — must be synced manually -->
<!-- - Framework X dropped API Y in version Z; use W instead -->

## References

- See `CONTRIBUTING.md` for the contribution workflow
- See `.claude/skills/` for stack-specific conventions loaded per task
- [Link to the data model / API spec / architecture doc if any]
