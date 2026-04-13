# [Project name]

[One-liner project description.]

## Stack

- **Backend**: Node.js / Express 5 / Prisma 7 / PostgreSQL / Redis
- **Frontend**: React 19 / Vite / Tailwind v4
- **Infra**: [process manager — PM2 / systemd / Docker], GitHub Actions CI/CD

## Structure

```
backend/     → REST API (controllers/, services/, middleware/, prisma/)
frontend/    → React SPA (pages/, components/, hooks/, i18n/)
```

## Commands

```bash
cd backend && npm run dev       # Backend dev (nodemon)
cd backend && npm test          # Tests (Vitest)
cd backend && npm run lint      # ESLint
cd frontend && npm run dev      # Frontend dev (Vite)
cd frontend && npm run build    # Production build
```

## Conventions

- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`
- JSDoc on public functions
- Thin controllers → logic lives in `services/`
- Every authenticated route goes through the JWT middleware
- Zod validation on every endpoint
- No `console.log` in production — use the logger

## Git workflow

- `main` = production (protected, PR-only merges)
- `dev` = integration
- Branches: `feat/xxx`, `fix/xxx`
- PR required with a description

## Gotchas

<!-- Project-specific pitfalls — the highest-value section -->
<!-- Examples: -->
<!-- - Seed requires an empty DB, otherwise unique constraint error -->
<!-- - .env is not copied by the deploy script -->
<!-- - Express 5 dropped app.del(), use app.delete() -->

## References

- See `CONTRIBUTING.md` for the contribution workflow
- See `prisma/schema.prisma` for the data model
- See `.claude/skills/` for per-domain conventions
