# [Nom du projet]

[Description one-liner du projet.]

## Stack

- **Backend**: Node.js / Express 5 / Prisma 7 / PostgreSQL / Redis
- **Frontend**: React 19 / Vite / Tailwind v4
- **Infra**: PM2, GitHub Actions CI/CD

## Structure

```
backend/     → API REST (controllers/, services/, middleware/, prisma/)
frontend/    → React SPA (pages/, components/, hooks/, i18n/)
```

## Commands

```bash
cd backend && npm run dev       # Backend dev (nodemon)
cd backend && npm test          # Tests (Vitest)
cd backend && npm run lint      # ESLint
cd frontend && npm run dev      # Frontend dev (Vite)
cd frontend && npm run build    # Build prod
```

## Conventions

- Conventional commits : `feat:`, `fix:`, `chore:`, `docs:`
- TypeScript-style JSDoc sur les fonctions publiques
- Controllers minces → logique dans `services/`
- Toute route auth via middleware JWT
- Validation Zod sur chaque endpoint
- Pas de `console.log` en prod — utiliser le logger

## Git workflow

- `main` = prod (protégée, merge via PR uniquement)
- `dev` = intégration
- Branches : `feat/xxx`, `fix/xxx`
- PR obligatoire avec description

## Gotchas

<!-- Les pièges spécifiques à ton projet — section la plus high-value -->
<!-- Exemples : -->
<!-- - Le seed nécessite une DB vide, sinon erreur de contrainte unique -->
<!-- - Le .env n'est pas copié par le script de deploy -->
<!-- - Express 5 ne supporte pas app.del(), utiliser app.delete() -->

## Références

- Voir `CONTRIBUTING.md` pour le workflow de contribution
- Voir `prisma/schema.prisma` pour le modèle de données
- Voir `.claude/skills/` pour les conventions détaillées par domaine
