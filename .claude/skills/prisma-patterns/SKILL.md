---
name: prisma-patterns
description: Conventions et patterns Prisma 7. Active quand on travaille sur le schema Prisma, les migrations, les queries, ou les services qui appellent Prisma.
allowed-tools: Read, Grep, Glob
---

# Prisma 7 — Conventions projet

## Schema

- Un model par entité métier. Pas de tables techniques visibles dans le schema (sauf sessions/tokens).
- Relations explicites avec `@relation`. Toujours nommer les relations quand il y a ambiguïté.
- `@updatedAt` sur tous les models qui ont du contenu modifiable.
- `@default(cuid())` pour les IDs string, `@default(autoincrement())` pour les IDs int.
- Enums pour les valeurs fixes (rôles, statuts, visibilité).

## Queries

- **Toujours `select` ou `include` explicite.** Jamais de `findMany()` sans filtre sur un model avec beaucoup de données.
- **Éviter N+1** : utiliser `include` avec les relations nécessaires plutôt que des boucles avec `findUnique`.
- **Pagination cursor-based** pour les listes longues (feed, search results). Pattern :
  ```js
  const items = await prisma.model.findMany({
    take: limit + 1,
    cursor: cursor ? { id: cursor } : undefined,
    skip: cursor ? 1 : 0,
    orderBy: { createdAt: 'desc' }
  });
  const hasMore = items.length > limit;
  if (hasMore) items.pop();
  ```
- **Transactions** pour les opérations multi-model qui doivent être atomiques.

## Migrations

- `npx prisma migrate dev --name description-courte` en dev.
- Jamais `db push` en prod. Toujours `migrate deploy`.
- Vérifier les migrations générées avant de commit — Prisma peut générer des `DROP` inattendus.

## Seed

- `prisma/seed.js` ou `prisma/seed.ts`. Idempotent : utiliser `upsert` plutôt que `create`.
- Données de seed réalistes, pas de "test123".

## Anti-patterns

- ❌ `prisma.$queryRaw` sauf cas exceptionnel (full-text search, fonctions SQL spécifiques)
- ❌ `deleteMany()` sans `where` — toujours expliciter le filtre
- ❌ Nested writes trop profonds (> 2 niveaux) — découper en transactions séquentielles
- ❌ Oublier les index sur les champs fréquemment filtrés (`@@index`)
