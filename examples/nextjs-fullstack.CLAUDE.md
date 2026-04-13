# Next.js fullstack app

A fullstack web app using Next.js 15 App Router, Prisma, and Tailwind v4.

## Stack

- **Framework**: Next.js 15 (App Router, Server Components, Server Actions)
- **Database**: PostgreSQL via Prisma 7
- **Styling**: Tailwind v4
- **Auth**: Auth.js v5 (session cookies, JWT strategy)
- **Testing**: Vitest (unit) + Playwright (e2e)
- **Hosting**: Vercel

## Structure

```
app/                  → App Router routes (server components by default)
  (auth)/             → Auth-protected route group
  api/                → Route handlers (REST-style endpoints)
components/           → Shared React components
  ui/                 → Primitives (button, input, dialog)
lib/
  db.ts               → Prisma singleton
  auth.ts             → Auth.js config
  actions/            → Server Actions (form submissions, mutations)
prisma/
  schema.prisma       → Data model
  migrations/         → Migration history
```

## Commands

```bash
npm run dev               # Next.js dev server on :3000
npm run build             # Production build
npm run lint              # ESLint + Next.js rules
npm test                  # Vitest
npm run test:e2e          # Playwright
npx prisma migrate dev    # Apply migrations locally
npx prisma studio         # DB inspector
```

## Conventions

- Prefer Server Components — only use `"use client"` when you need state, effects, or browser APIs
- Mutations go through Server Actions, not API routes
- Zod schemas for all Server Action inputs
- Use `next/image` for every image — never raw `<img>`
- Use `next/link` for internal navigation — never raw `<a href="/...">`
- Colocate loading.tsx, error.tsx, and not-found.tsx next to page.tsx

## Git workflow

- `main` = production (auto-deploys to Vercel)
- Feature branches: `feat/xxx`, `fix/xxx`
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`

## Gotchas

- Prisma singleton in `lib/db.ts` — importing a new PrismaClient per request leaks connections in dev with hot reload
- Server Actions that use `redirect()` must not be wrapped in try/catch — `redirect` throws a special error that Next.js needs to propagate
- `revalidatePath` after every mutation that changes data shown on another route
- Environment variables: `NEXT_PUBLIC_*` ships to the client; everything else is server-only
- Playwright tests need the app built first in CI — `npm run build && npm run start` before `test:e2e`

## References

- `prisma/schema.prisma` for the data model
- `lib/auth.ts` for auth config and session shape
- [Next.js docs](https://nextjs.org/docs)
