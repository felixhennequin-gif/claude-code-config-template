---
name: prisma-patterns
description: Prisma 7 conventions and patterns. Activates when working on the Prisma schema, migrations, queries, or services that call Prisma.
---

# Prisma 7 — Project conventions

## Schema

- One model per domain entity. No technical tables surfaced in the schema (except sessions / tokens).
- Explicit relations via `@relation`. Always name the relation when there's ambiguity.
- `@updatedAt` on every model whose content can change.
- String IDs: prefer `@default(ulid())` (Prisma 7+) or `@default(uuid(7))` for new projects. `@default(cuid())` still works but cuid is in maintenance mode — avoid it in new schemas.
- Int IDs: `@default(autoincrement())`.
- Enums for fixed values (roles, statuses, visibility).

## Queries

- **Always use an explicit `select` or `include`.** Never `findMany()` without a filter on a large table.
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
- **`typedSql`** (Prisma 7+) — for complex queries that don't fit the query builder, use `prisma.$queryRawTyped()` with `.sql` files in `prisma/sql/`. This gives type-safe raw SQL without string interpolation. Prefer this over `$queryRaw` with template literals.
- **Transactions** for multi-model operations that must be atomic.

## Migrations

- `npx prisma migrate dev --name short-description` in dev.
- Never `db push` in production. Always `migrate deploy`.
- Review the generated migration before committing — Prisma may emit unexpected `DROP`s.

## Seed

- `prisma/seed.js` or `prisma/seed.ts`. Idempotent: prefer `upsert` over `create`.
- Realistic seed data — no `test123`.

## Anti-patterns

- ❌ `prisma.$queryRaw` with template literals — use typedSql (`$queryRawTyped` + `.sql` files) instead. Only fall back to `$queryRaw` for truly dynamic queries that can't be expressed as static SQL files.
- ❌ `deleteMany()` without a `where` — always spell out the filter
- ❌ Deeply nested writes (> 2 levels) — split into sequential transactions
- ❌ Missing `@@index` on fields that are frequently filtered
