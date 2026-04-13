---
name: express-api
description: Express 5 conventions and REST API patterns. Activates when working on routes, controllers, middleware, validation, or error handling in a Node.js/Express backend.
---

# Express 5 — API conventions

## Architecture

```
backend/
├── src/
│   ├── controllers/    # Thin — parse request, call service, send response
│   ├── services/       # Business logic, Prisma calls, validations
│   ├── middleware/     # Auth, validation, rate limiting, error handler
│   ├── validators/     # Zod schemas per resource
│   ├── routes/         # Route declarations, applies middleware
│   └── utils/          # Helpers, logger, constants
```

## Controllers

A controller does three things:
1. Extract data from `req` (params, body, query, user)
2. Call the corresponding service
3. Return the response with the right status code

```js
// GOOD
const getItem = async (req, res, next) => {
  const item = await itemService.getById(req.params.id, req.user?.id);
  res.json(item);
};

// BAD — business logic in the controller
const getItem = async (req, res, next) => {
  const item = await prisma.item.findUnique({ where: { id: req.params.id } });
  if (!item) throw new NotFoundError('Item not found');
  const ratings = await prisma.rating.aggregate({ /* ... */ });
  // 50 lines of logic...
};
```

## Validation

- Zod on EVERY endpoint. No exceptions.
- Schemas live in `validators/`. One file per resource.
- A `validate(schema)` middleware applied in the routes.

```js
// validators/item.validator.js
const createItemSchema = z.object({
  body: z.object({
    name: z.string().min(1).max(200),
    tags: z.array(z.string()).min(1),
    description: z.string().min(10),
  }),
});
```

## Error handling

- Custom error classes: `NotFoundError`, `UnauthorizedError`, `ValidationError`, `ForbiddenError`.
- All inherit from `AppError` with a `statusCode`.
- A single global error handler as the last middleware.
- **Never** wrap controllers in `try/catch` under Express 5 — async errors bubble up automatically.

## Status codes

- `200` — successful GET / PUT / PATCH
- `201` — successful POST creating a resource
- `204` — successful DELETE (no body)
- `400` — validation failed
- `401` — not authenticated
- `403` — authenticated but not authorized
- `404` — resource not found
- `409` — conflict (duplicate)
- `429` — rate limited
- `500` — server error (never expose stack traces in production)

## Auth middleware

- `authenticate` — verifies the JWT, attaches `req.user`
- `optionalAuth` — attempts to verify, doesn't block if absent
- `authorize(roles)` — role check, runs after `authenticate`

## Anti-patterns

- ❌ `res.status(200).json({ error: true })` — use real status codes
- ❌ Business logic inside controllers
- ❌ `app.del()` — removed in Express 5, use `app.delete()`
- ❌ Catch-all `try/catch` in every controller (pointless under Express 5)
- ❌ `req.body` without Zod validation
