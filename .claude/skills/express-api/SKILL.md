---
name: express-api
description: Conventions Express 5 et patterns API REST. Active quand on travaille sur les routes, controllers, middleware, validation, ou error handling.
allowed-tools: Read, Grep, Glob
---

# Express 5 — Conventions API

## Architecture

```
backend/
├── src/
│   ├── controllers/     # Thin — parse request, call service, send response
│   ├── services/        # Business logic, Prisma calls, validations
│   ├── middleware/       # Auth, validation, rate limiting, error handler
│   ├── validators/      # Zod schemas par resource
│   ├── routes/          # Déclaration des routes, applique middleware
│   └── utils/           # Helpers, logger, constants
```

## Controllers

Un controller fait 3 choses :
1. Extraire les données de `req` (params, body, query, user)
2. Appeler le service correspondant
3. Renvoyer la réponse avec le bon status code

```js
// BON
const getRecipe = async (req, res, next) => {
  const recipe = await recipeService.getById(req.params.id, req.user?.id);
  res.json(recipe);
};

// MAUVAIS — logique métier dans le controller
const getRecipe = async (req, res, next) => {
  const recipe = await prisma.recipe.findUnique({ where: { id: req.params.id } });
  if (!recipe) throw new NotFoundError('Recipe not found');
  const ratings = await prisma.rating.aggregate({ ... });
  // 50 lignes de logique...
};
```

## Validation

- Zod sur CHAQUE endpoint. Pas d'exception.
- Schémas dans `validators/`. Un fichier par resource.
- Middleware `validate(schema)` appliqué dans les routes.

```js
// validators/recipe.validator.js
const createRecipeSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(200),
    ingredients: z.array(ingredientSchema).min(1),
    instructions: z.string().min(10)
  })
});
```

## Error handling

- Custom error classes : `NotFoundError`, `UnauthorizedError`, `ValidationError`, `ForbiddenError`.
- Toutes héritent de `AppError` avec un `statusCode`.
- Un seul error handler global en dernier middleware.
- **Jamais** de `try/catch` dans les controllers avec Express 5 — les erreurs async remontent automatiquement.

## Status codes

- `200` : GET réussi, PUT/PATCH réussi
- `201` : POST création réussie
- `204` : DELETE réussi (pas de body)
- `400` : Validation échouée
- `401` : Non authentifié
- `403` : Authentifié mais pas autorisé
- `404` : Resource introuvable
- `409` : Conflit (duplicate)
- `429` : Rate limited
- `500` : Erreur serveur (ne jamais exposer le stack trace en prod)

## Middleware auth

- `authenticate` : vérifie le JWT, attache `req.user`
- `optionalAuth` : tente de vérifier, mais ne bloque pas si absent
- `authorize(roles)` : vérifie le rôle après authenticate

## Anti-patterns

- ❌ `res.status(200).json({ error: true })` — utiliser les vrais status codes
- ❌ Logique métier dans les controllers
- ❌ `app.del()` — supprimé dans Express 5, utiliser `app.delete()`
- ❌ Catch-all `try/catch` dans chaque controller (inutile avec Express 5)
- ❌ `req.body` sans validation Zod
