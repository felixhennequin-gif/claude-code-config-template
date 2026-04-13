# LeCabanon

Collaborative web app for sharing tools and recommending local craftspeople between neighbors. Monorepo with `/backend` + `/frontend`.

## Stack

- **Backend**: Node.js (ESM) / Express 5 / Prisma 7 (@prisma/adapter-pg) / PostgreSQL
- **Frontend**: React 19 / Vite 8 / React Router v7 / Tailwind CSS v4 (Vite plugin)
- **Auth**: JWT (access + refresh) + Google OAuth (Passport)
- **Realtime**: Socket.io (messaging)
- **Validation**: Zod 4 + React Hook Form
- **Upload**: Multer + Sharp (WebP, local `/uploads/` storage)
- **Infra**: PM2 (port 3002), GitHub Actions CI on push/PR to `main` and `dev`

## Structure

```
backend/
├── src/
│   ├── controllers/     # Route handlers
│   ├── services/        # Business logic
│   ├── middleware/      # JWT auth, Zod validation, error handler
│   ├── routes/          # Route declarations
│   └── socket/          # Socket.io handlers (messaging)
frontend/
├── src/
│   ├── pages/           # Page components
│   ├── components/      # UI (workshop/DIY design system)
│   ├── hooks/           # Custom hooks
│   ├── services/        # API calls
│   ├── i18n/            # FR (extensible)
│   └── contexts/        # Auth, Theme, Socket
```

## Commands

```bash
cd backend && npm run dev         # Backend (nodemon)
cd backend && npm test            # Tests (Vitest)
cd backend && npm run lint        # ESLint
cd frontend && npm run dev        # Frontend (Vite)
cd frontend && npm run build      # Production build
npx prisma migrate dev            # Migrations
./scripts/demo.sh                 # Install + build + seed + pm2
```

## Conventions

- Conventional commits: `feat:`, `fix:`, `chore:`
- Thin controllers → logic lives in `services/`
- Zod validation on every endpoint
- JWT access/refresh auth + Google OAuth
- i18n: `/:lang/` routes, redirect `/` → `/fr/`
- Layout split: `PublicLayout`, `AppLayout`, `AuthLayout`

## Design system

- Typography: Plus Jakarta Sans (700 headings, 400/500 body)
- Palette: warm backgrounds (cream light `#f5f2ec`, dark brown `#1c1b18`), no pure white/black
- Primary: green `#5ba368`; Accent: copper `#c47a4a`; Warm: gold `#d4a840`
- Border radius: cards 14px, buttons 10px, pills 24px
- Icons: Lucide React, stroke-width 1.5
- Dark mode: class-based with system detection + toggle

## Data model

12 Prisma models: `User`, `Community`, `CommunityMember`, `Equipment`, `Artisan`, `ArtisanCommunity`, `Review`, `ReviewMedia`, `ReviewReply`, `Activity`, `Invitation`, `Conversation`, `Message`.

## Gotchas

- Tailwind v4: configured via the Vite plugin, NO `tailwind.config.js`
- Express 5: no `app.del()`
- Upload: 5 MB max, automatic WebP conversion via Sharp
- Socket.io: `/messaging` namespace, JWT auth in the handshake
- Seed uses real data (Jacques Urugen, avenue Guillon)
- The landing footer is unreachable (sticky header + `min-h-screen`, known bug)

## V1 roadmap

- [x] Blocks 0–5 shipped (design system, i18n, marketing, legal, profile, polish)
- [ ] Block 6: Go live (domain, Cloudflare Tunnel, transactional email)

## References

- `prisma/schema.prisma` for the data model
- `.claude/skills/` for detailed conventions
