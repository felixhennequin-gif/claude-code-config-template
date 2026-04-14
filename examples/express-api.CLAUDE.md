# Express REST API

A JSON REST API built with Express 5, Prisma, and PostgreSQL.

## Stack

- **Runtime**: Node.js 22 (LTS)
- **Framework**: Express 5
- **Database**: PostgreSQL via Prisma 7
- **Validation**: Zod
- **Auth**: JWT (access + refresh tokens)
- **Testing**: Vitest + Supertest
- **Logger**: Pino

## Structure

```
src/
  index.js              → Entry point (creates server, registers middleware)
  app.js                → Express app factory (used by tests too)
  routes/               → Route definitions, one file per resource
  controllers/          → Thin — parse input, call service, format response
  services/             → Business logic, Prisma calls
  middleware/
    auth.js             → JWT verification
    error.js            → Central error handler
    validate.js         → Zod schema runner
  schemas/              → Zod schemas per endpoint
  lib/
    prisma.js           → Prisma singleton
    logger.js           → Pino instance
prisma/
  schema.prisma
  migrations/
tests/                  → Integration tests against a real test database
```

## Commands

```bash
npm run dev               # nodemon on :4000
npm start                 # Production
npm test                  # Vitest (unit + integration)
npm run lint              # ESLint
npx prisma migrate dev    # Apply migrations locally
npx prisma migrate deploy # Apply migrations in CI/prod
```

## Conventions

- Controllers stay thin — all logic lives in `services/`
- Every authenticated route goes through the `auth` middleware
- Every endpoint validates its body/query/params with a Zod schema via the `validate` middleware
- Errors are thrown, never returned — the central error middleware formats them
- Use the Pino logger — no `console.log` in production code
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`

## Git workflow

- `main` = production (protected, PR-only)
- `dev` = integration branch
- Branches: `feat/xxx`, `fix/xxx`

## Gotchas

- Express 5 changes error handling — async route handlers now propagate rejections automatically, so the old `express-async-handler` wrapper is unnecessary
- Prisma singleton in `src/lib/prisma.js` — creating a new client per request exhausts the connection pool fast
- Integration tests hit a real DB (not a mock) — use a separate `DATABASE_URL_TEST` and truncate tables in `beforeEach`
- JWT secret rotation: verify with both the current and previous secret during the rotation window
- `express.json()` limit defaults to 100kb — bump it explicitly for endpoints that accept larger payloads

## References

- `prisma/schema.prisma` for the data model
- `src/middleware/error.js` for the error format contract
- [Express 5 migration notes](https://expressjs.com/en/guide/migrating-5.html)
