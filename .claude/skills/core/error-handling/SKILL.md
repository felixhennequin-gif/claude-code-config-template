---
name: error-handling
description: Universal error handling patterns. Activates when writing error handling code, creating error classes, working with try/catch blocks, or implementing error middleware in any language or stack.
---

# Error handling

Four rules that apply to every language and stack.

> The rules are language-agnostic. Sections 3 and 4 show parallel
> JavaScript and Python examples to make that concrete. The same shape
> maps to Flask, Django, Gin, Axum, and any other framework — only the
> hook name for the centralized error handler changes.

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

```python
# Python equivalent — same shape, same rule:
class AppError(Exception):
    def __init__(self, message: str, status: int = 500):
        super().__init__(message)
        self.status = status

class NotFoundError(AppError):
    def __init__(self, resource: str):
        super().__init__(f"{resource} not found", 404)

raise NotFoundError("User")
```

## 4. Classify at the outermost boundary, propagate typed errors everywhere else

A single **centralized error handler** at the outermost layer maps error types to the protocol's response codes. Business logic throws typed errors; the handler translates them. Service and repository layers must not know about the protocol. Every mainstream web framework ships a hook for this handler — Express middleware, FastAPI `exception_handler`, Flask `errorhandler`, Django middleware, Gin `Use(ErrorHandler())`, Axum `HandleErrorLayer` — the name varies, the shape doesn't.

**Shared service layer (language-neutral in intent):**

```js
// service: throws typed errors, knows nothing about HTTP
async function getUser(id, actor) {
  const user = await repo.findById(id);
  if (!user) throw new NotFoundError('User');
  if (!canRead(actor, user)) throw new ForbiddenError('User');
  return user;
}
```

**BAD — mapping scattered across controllers, duplicated on every route:**

```js
app.get('/users/:id', async (req, res) => {
  const user = await getUser(req.params.id);
  if (!user) return res.status(404).json({ error: 'not found' });
  if (!canRead(req.user, user)) return res.status(403).json({ error: 'forbidden' });
  res.json(user);
});
```

**GOOD — one handler, every route benefits. Express 5:**

```js
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

**GOOD — same pattern, FastAPI:**

```python
# boundary (runs once, for every route)
STATUS_MAP = {
    NotFoundError: 404,
    UnauthorizedError: 401,
    ForbiddenError: 403,
    ValidationError: 400,
    ConflictError: 409,
}

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError):
    status = STATUS_MAP.get(type(exc), 500)
    if status == 500:
        logger.error("unhandled error", exc_info=exc)
    return JSONResponse(status_code=status, content={"error": str(exc)})
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
