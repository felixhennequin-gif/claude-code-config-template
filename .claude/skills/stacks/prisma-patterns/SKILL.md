---
name: prisma-patterns
description: Prisma ORM conventions and patterns. Activates when working on the Prisma schema, migrations, queries, or services that call Prisma.
last-verified: 2026-04-16
---

# Prisma — Project conventions

Applies to Prisma 6.x and 7.x. Preview-only features are flagged inline.

## Schema

- One model per domain entity. No technical tables surfaced in the schema (except sessions / tokens).
- Explicit relations via `@relation`. Always name the relation when there's ambiguity.
- `@updatedAt` on every model whose content can change.
- String IDs: prefer `@default(uuid(7))` (Prisma 5.18+) for new projects — UUIDv7 is time-ordered, which keeps B-tree indexes happy. `@default(cuid())` still works but cuid is in maintenance mode per the Prisma team — avoid it in new schemas. Do **not** use `@default(ulid())` — ULID is not a native Prisma generator; use `uuid(7)` or wire a manual `@default` via `dbgenerated` if you truly need ULID.
- Int IDs: `@default(autoincrement())`.
- Enums for fixed values (roles, statuses, visibility).

## Queries

- **Always use an explicit `select` or `include`.** Never `findMany()` without a filter on a large table.
- **`omit` for sensitive fields** (GA in Prisma 6.2+) — exclude fields like `password` or `secret` at the query level instead of manual `select`:
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
- **`typedSql`** ⚠️ **Preview feature** since Prisma 5.19 — still preview as of **last verified 2026-04-15**. Re-check [Prisma's preview-features list](https://www.prisma.io/docs/orm/reference/preview-features) before adopting, because preview flags can break, rename, or get removed between minor releases. When you're comfortable pinning a Prisma version and revisiting on upgrades, enable with `previewFeatures = ["typedSql"]` in the generator block, put `.sql` files under `prisma/sql/`, and call them via `prisma.$queryRawTyped()` — this gives type-safe raw SQL without string interpolation. On a production codebase that can't absorb preview churn, stay on `$queryRaw` with careful review instead.
- **Transactions** for multi-model operations that must be atomic.

## Migrations

- `npx prisma migrate dev --name short-description` in dev.
- Never `db push` in production. Always `migrate deploy`.
- Review the generated migration before committing — Prisma may emit unexpected `DROP`s.

## Seed

- `prisma/seed.js` or `prisma/seed.ts`. Idempotent: prefer `upsert` over `create`.
- Realistic seed data — no `test123`.

## Anti-patterns

- ❌ `prisma.$queryRaw` with unchecked template literals — if the `typedSql` preview flag is acceptable for your project, prefer `$queryRawTyped` + `.sql` files. If you can't depend on preview flags, stay on `$queryRaw` but sanitize inputs yourself and review each call carefully. Either way, only use raw SQL when the query builder can't express the query.
- ❌ `deleteMany()` without a `where` — always spell out the filter
- ❌ Deeply nested writes (> 2 levels) — split into sequential transactions
- ❌ Missing `@@index` on fields that are frequently filtered
