# Écume (cocktail-app)

Cocktail web app with social features. MVP complete, heading toward monetization.

## Stack

- **Backend**: Node.js / Express 5 / Prisma 7 / PostgreSQL / Redis (ioredis)
- **Frontend**: React 19 / Vite 7 / Tailwind v4
- **Infra**: PM2, Cloudflare Tunnel, Nginx, GitHub Actions CI/CD
- **Email**: Resend (configured, flows not yet active)
- **Payments**: Stripe (planned)

## Structure

```
backend/
├── src/
│   ├── controllers/     # Thin route handlers
│   ├── services/        # Business logic + Prisma
│   ├── middleware/      # JWT auth, validation, rate limiting, error handler
│   ├── validators/      # Zod schemas
│   └── routes/          # Route declarations
frontend/
├── src/
│   ├── pages/           # Page components
│   ├── components/      # Reusable UI
│   ├── hooks/           # Custom hooks
│   ├── services/        # API calls
│   ├── i18n/            # FR/EN
│   └── contexts/        # Auth, Theme
```

## Commands

```bash
cd backend && npm run dev         # Backend (nodemon)
cd backend && npm test            # 197 tests (Vitest)
cd backend && npm run lint        # ESLint
cd frontend && npm run dev        # Frontend (Vite)
cd frontend && npm run build      # Production build
npx prisma migrate dev            # Migrations
npx prisma studio                 # DB GUI
```

## Conventions

- Conventional commits: `feat:`, `fix:`, `chore:`
- Thin controllers → logic lives in `services/`
- Zod validation on every endpoint
- JWT auth with refresh token rotation
- Redis: cache with graceful degradation (app works without Redis)
- i18n: FR/EN, files in `frontend/src/i18n/`

## Domain

- `cocktail-app.fr` (OVH)
- Deploy: PM2 processes `cocktail-api`, `cocktail-api-dev`, `ecume-api`
- CI/CD: HMAC SHA-256 webhook + `deploy.sh`

## Gotchas

- Express 5: no `app.del()`, use `app.delete()`
- The service worker caches `thecocktaildb` and causes cache poisoning (known bug)
- `RecipeDetail` crashes on `/recipes/55` (incomplete diagnosis)
- Dark mode + i18n merge potentially unstable
- Seed requires PostgreSQL + Redis running
- Redis is optional: `lazyConnect: true` + try/catch on every call

## Open work

- Resend email flows (5 prompts ready)
- Stripe freemium monetization ~€4/month (6 prompts ready)
- URL slug migration
- Final naming: Écume vs Zeste

## References

- `prisma/schema.prisma` for the data model
- `.claude/skills/` for detailed conventions
