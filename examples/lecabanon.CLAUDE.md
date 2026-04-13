# LeCabanon

App web collaborative de partage de matériel et recommandation d'artisans entre voisins. Monorepo `/backend` + `/frontend`.

## Stack

- **Backend**: Node.js (ESM) / Express 5 / Prisma 7 (@prisma/adapter-pg) / PostgreSQL
- **Frontend**: React 19 / Vite 8 / React Router v7 / Tailwind CSS v4 (plugin Vite)
- **Auth**: JWT (access + refresh) + Google OAuth (Passport)
- **Temps réel**: Socket.io (messagerie)
- **Validation**: Zod 4 + React Hook Form
- **Upload**: Multer + Sharp (WebP, stockage local /uploads/)
- **Infra**: PM2 (port 3002), GitHub Actions CI sur push/PR vers main et dev

## Structure

```
backend/
├── src/
│   ├── controllers/      # Handlers routes
│   ├── services/         # Logique métier
│   ├── middleware/        # Auth JWT, validation Zod, error handler
│   ├── routes/           # Déclaration routes
│   └── socket/           # Handlers Socket.io (messagerie)
frontend/
├── src/
│   ├── pages/            # Composants page
│   ├── components/       # UI (design system atelier/bricolage)
│   ├── hooks/            # Custom hooks
│   ├── services/         # Appels API
│   ├── i18n/             # FR (extensible)
│   └── contexts/         # Auth, Theme, Socket
```

## Commands

```bash
cd backend && npm run dev         # Backend (nodemon)
cd backend && npm test            # Tests (Vitest)
cd backend && npm run lint        # ESLint
cd frontend && npm run dev        # Frontend (Vite)
cd frontend && npm run build      # Build prod
npx prisma migrate dev            # Migrations
./scripts/demo.sh                 # Install + build + seed + pm2
```

## Conventions

- Conventional commits : `feat:`, `fix:`, `chore:`
- Controllers minces → logique dans services/
- Validation Zod sur chaque endpoint
- Auth JWT access/refresh + Google OAuth
- i18n : routes /:lang/, redirect / → /fr/
- Layout split : PublicLayout, AppLayout, AuthLayout

## Design system

- Typo : Plus Jakarta Sans (700 headings, 400/500 body)
- Palette : fonds chauds (crème light #f5f2ec, brun dark #1c1b18), zéro blanc/noir pur
- Primary : vert #5ba368, Accent : cuivre #c47a4a, Warm : doré #d4a840
- Border-radius : cards 14px, boutons 10px, pills 24px
- Icônes : Lucide React, stroke-width 1.5
- Dark mode : class-based avec détection système + toggle

## Modèle de données

12 models Prisma : User, Community, CommunityMember, Equipment, Artisan, ArtisanCommunity, Review, ReviewMedia, ReviewReply, Activity, Invitation, Conversation, Message.

## Gotchas

- Tailwind v4 : config via plugin Vite, PAS de tailwind.config.js
- Express 5 : pas de `app.del()`
- Upload : max 5 Mo, conversion WebP automatique via Sharp
- Socket.io : namespace `/messaging`, auth via JWT dans handshake
- Seed utilise des données réelles (Jacques Urugen, avenue Guillon)
- Le footer landing est inaccessible (sticky header + min-h-screen, bug ouvert)

## Roadmap V1

- [x] Blocs 0-5 livrés (design system, i18n, marketing, légales, profil, polish)
- [ ] Bloc 6 : Mise en ligne (domaine, Cloudflare Tunnel, email transactionnel)

## Références

- `prisma/schema.prisma` pour le modèle de données
- `.claude/skills/` pour les conventions détaillées
