---
name: error-handling
description: Universal error handling patterns. Activates when writing error handling code, creating error classes, working with try/catch blocks, or implementing error middleware in any language or stack.
---

# Error handling

Four rules that apply to every language and stack.

## 1. Fail loudly at the boundary, silently never

Errors should propagate up to the layer that can handle them meaningfully. Never swallow an error silently. The right default in intermediate layers is **no try/catch at all** — not a rethrow. Wrapping a call only to rethrow is a no-op that linters (ESLint `no-useless-catch`) already flag.

```js
// BAD — error is gone, caller thinks it succeeded
try {
  await doSomething();
} catch (e) {}

// GOOD — let it propagate naturally. No try/catch needed here.
// Errors bubble up to the boundary (e.g. Express 5 error middleware,
// or an outer try/catch in the entry point) where they're logged once.
await doSomething();
```

## 2. Fix at the root, not the symptom

If a function can return null/undefined/error, fix the function — don't add null checks everywhere it's called. The caller shouldn't have to defend against bad state that the callee should never produce.

## 3. Typed errors over string messages

Use typed error classes so callers can distinguish error types programmatically, not by parsing strings.

```js
// BAD
throw new Error('Not found');

// GOOD
class NotFoundError extends AppError {
  constructor(resource) {
    super(`${resource} not found`, 404);
  }
}
throw new NotFoundError('User');
```

## 4. Classify at the HTTP boundary, propagate typed errors everywhere else

The HTTP layer is the only place that maps error types to status codes. Business logic throws typed errors; the error middleware (or equivalent) translates them into responses. Service and repository layers must not know about HTTP.

```js
// BAD — mapping scattered across controllers, duplicated on every route
app.get('/users/:id', async (req, res) => {
  const user = await getUser(req.params.id);
  if (!user) return res.status(404).json({ error: 'not found' });
  if (!canRead(req.user, user)) return res.status(403).json({ error: 'forbidden' });
  res.json(user);
});

// GOOD — services throw typed errors, one middleware maps them
// service layer:
async function getUser(id, actor) {
  const user = await repo.findById(id);
  if (!user) throw new NotFoundError('User');
  if (!canRead(actor, user)) throw new ForbiddenError('User');
  return user;
}

// boundary (runs once, for every route):
const STATUS_MAP = {
  NotFoundError: 404,
  UnauthorizedError: 401,
  ForbiddenError: 403,
  ValidationError: 400,
  ConflictError: 409,
};
app.use((err, req, res, _next) => {
  const status = STATUS_MAP[err.constructor.name] ?? 500;
  if (status === 500) logger.error({ err }, 'unhandled error');
  res.status(status).json({ error: err.message });
});
```

The same pattern applies to any boundary that speaks a protocol: gRPC status codes, GraphQL error extensions, message-queue DLQ routing. Only one place per boundary owns the mapping.

## Anti-patterns

- ❌ Empty catch blocks (`catch {}` / `except: pass`)
- ❌ `catch (e) { return null }` — turns errors into silent wrong behavior
- ❌ Checking error message strings (`if (e.message.includes('not found')`)
- ❌ Re-throwing a different error type that loses the original stack trace — use `cause`: `throw new AppError('msg', { cause: e })`
- ❌ Logging AND rethrowing at every layer — log once at the top boundary
- ❌ HTTP status codes inside the service layer — services don't know about HTTP
- ❌ Duplicating the status-code mapping across controllers — do it once in the error middleware
