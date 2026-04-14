---
name: prisma-patterns
description: Prisma ORM conventions and patterns. Activates when working on the Prisma schema, migrations, queries, or services that call Prisma.
---

# Prisma — Project conventions

Applies to Prisma 5.x and 6.x. Preview-only features are flagged inline.

## Schema

- One model per domain entity. No technical tables surfaced in the schema (except sessions / tokens).
- Explicit relations via `@relation`. Always name the relation when there's ambiguity.
- `@updatedAt` on every model whose content can change.
- String IDs: prefer `@default(uuid(7))` (Prisma 5.18+) for new projects — UUIDv7 is time-ordered, which keeps B-tree indexes happy. `@default(cuid())` still works but cuid is in maintenance mode per the Prisma team — avoid it in new schemas. Do **not** use `@default(ulid())` — ULID is not a native Prisma generator; use `uuid(7)` or wire a manual `@default` via `dbgenerated` if you truly need ULID.
- Int IDs: `@default(autoincrement())`.
- Enums for fixed values (roles, statuses, visibility).

## Queries

- **Always use an explicit `select` or `include`.** Never `findMany()` without a filter on a large table.
- **`omit` for sensitive fields** (Prisma 5.13+/7) — exclude fields like `password` or `secret` at the query level instead of manual `select`:
  ```js
  const user = await prisma.user.findUnique({
    where: { id },
    omit: { password: true },
  });
  ```
  Prefer this over `select`-ing every field individually when you only want to hide one or two.
- **Avoid N+1:** use `include` with the needed relations rather than loops calling `findUnique`.
- **Cursor-based pagination** for long lists (feed, search results). Pattern:
  ```js
  const items = await prisma.model.findMany({
    take: limit + 1,
    cursor: cursor ? { id: cursor } : undefined,
    skip: cursor ? 1 : 0,
    orderBy: { createdAt: 'desc' },
  });
  const hasMore = items.length > limit;
  if (hasMore) items.pop();
  ```
- **`typedSql`** (preview since Prisma 5.19 — enable with `previewFeatures = ["typedSql"]` in the generator block) — for complex queries that don't fit the query builder, put `.sql` files under `prisma/sql/` and call them via `prisma.$queryRawTyped()`. This gives type-safe raw SQL without string interpolation. Prefer this over `$queryRaw` with template literals where the preview flag is acceptable.
- **Transactions** for multi-model operations that must be atomic.

## Migrations

- `npx prisma migrate dev --name short-description` in dev.
- Never `db push` in production. Always `migrate deploy`.
- Review the generated migration before committing — Prisma may emit unexpected `DROP`s.

## Seed

- `prisma/seed.js` or `prisma/seed.ts`. Idempotent: prefer `upsert` over `create`.
- Realistic seed data — no `test123`.

## Anti-patterns

- ❌ `prisma.$queryRaw` with template literals — use typedSql (`$queryRawTyped` + `.sql` files) instead, where the preview flag is acceptable. Only fall back to `$queryRaw` for truly dynamic queries that can't be expressed as static SQL files.
- ❌ `deleteMany()` without a `where` — always spell out the filter
- ❌ Deeply nested writes (> 2 levels) — split into sequential transactions
- ❌ Missing `@@index` on fields that are frequently filtered
