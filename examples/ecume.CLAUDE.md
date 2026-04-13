# Écume (cocktail-app)

Application web de cocktails avec fonctionnalités sociales. MVP complet, en route vers la monétisation.

## Stack

- **Backend**: Node.js / Express 5 / Prisma 7 / PostgreSQL / Redis (ioredis)
- **Frontend**: React 19 / Vite 7 / Tailwind v4
- **Infra**: PM2, Cloudflare Tunnel, Nginx, GitHub Actions CI/CD
- **Email**: Resend (configuré, flows pas encore actifs)
- **Paiement**: Stripe (planifié)

## Structure

```
backend/
├── src/
│   ├── controllers/      # Routes handlers (minces)
│   ├── services/         # Logique métier + Prisma
│   ├── middleware/        # Auth JWT, validation, rate limiting, error handler
│   ├── validators/       # Schémas Zod
│   └── routes/           # Déclaration routes
frontend/
├── src/
│   ├── pages/            # Composants page
│   ├── components/       # UI réutilisable
│   ├── hooks/            # Custom hooks
│   ├── services/         # Appels API
│   ├── i18n/             # FR/EN
│   └── contexts/         # Auth, Theme
```

## Commands

```bash
cd backend && npm run dev         # Backend (nodemon)
cd backend && npm test            # 197 tests (Vitest)
cd backend && npm run lint        # ESLint
cd frontend && npm run dev        # Frontend (Vite)
cd frontend && npm run build      # Build prod
npx prisma migrate dev            # Migrations
npx prisma studio                 # GUI DB
```

## Conventions

- Conventional commits : `feat:`, `fix:`, `chore:`
- Controllers minces → logique dans services/
- Validation Zod sur chaque endpoint
- Auth JWT avec refresh token rotation
- Redis : cache avec graceful degradation (app marche sans Redis)
- i18n : FR/EN, fichiers dans frontend/src/i18n/

## Domaine

- `cocktail-app.fr` (OVH)
- Deploy : PM2 processes `cocktail-api`, `cocktail-api-dev`, `ecume-api`
- CI/CD : webhook HMAC SHA-256 + `deploy.sh`

## Gotchas

- Express 5 : pas de `app.del()`, utiliser `app.delete()`
- Le SW cache thecocktaildb et cause du cache poisoning (bug ouvert)
- RecipeDetail crash sur /recipes/55 (diagnostic incomplet)
- Dark mode + i18n merge potentiellement instable
- Le seed nécessite PostgreSQL + Redis running
- Redis optionnel : `lazyConnect: true` + try/catch sur chaque appel

## Chantiers ouverts

- Email flows Resend (5 prompts prêts)
- Stripe monétisation freemium ~4€/mois (6 prompts prêts)
- Migration slugs URLs
- Naming définitif : Écume vs Zeste

## Références

- `prisma/schema.prisma` pour le modèle de données
- `.claude/skills/` pour les conventions détaillées
