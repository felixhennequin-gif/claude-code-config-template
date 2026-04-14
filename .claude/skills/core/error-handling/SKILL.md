---
name: error-handling
description: Universal error handling patterns. Activates when writing error handling code, creating error classes, working with try/catch blocks, or implementing error middleware in any language or stack.
---

# Error handling

Three rules that apply to every language and stack.

## 1. Fail loudly at the boundary, silently never

Errors should propagate up to the layer that can handle them meaningfully. Never swallow an error silently.

```js
// BAD — error is gone, caller thinks it succeeded
try {
  await doSomething();
} catch (e) {}

// GOOD — let it propagate. Logging happens once at the top boundary
// (e.g. an error middleware), not at every intermediate layer.
try {
  await doSomething();
} catch (e) {
  throw e;
}
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

## Anti-patterns

- ❌ Empty catch blocks (`catch {}` / `except: pass`)
- ❌ `catch (e) { return null }` — turns errors into silent wrong behavior
- ❌ Checking error message strings (`if (e.message.includes('not found')`)
- ❌ Re-throwing a different error type that loses the original stack trace — use `cause`: `throw new AppError('msg', { cause: e })`
- ❌ Logging AND rethrowing at every layer — log once at the top boundary
