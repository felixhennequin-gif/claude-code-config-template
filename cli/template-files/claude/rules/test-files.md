<!--
Path-scoped project rule — loaded by Claude Code when editing matching files.
Mechanism: https://code.claude.com/docs/en/memory#path-specific-rules
The correct frontmatter field is `paths:` (Claude Code), not `globs:` (Cursor).
-->
---
name: test-files
description: Rules for test files. Loaded only when working with files matching *.test.* or *.spec.* patterns.
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/tests/**"
  - "**/__tests__/**"
---

# Test file conventions

## Framework
- Use the project's existing test runner — don't switch frameworks without asking
- Check `package.json` scripts, `Makefile`, `pyproject.toml`, or CI config for the correct test command
- If no test infrastructure exists, ask the user which framework to use before creating test files

## Structure
- Test files colocated next to source OR in a `tests/` directory — pick one per project, be consistent
- Name: `[module].test.js` or `[module].spec.js` — adapt the extension to match the project's language (`.test.ts`, `test_module.py`, `_test.go`, etc.)
- Group with `describe()` (or the equivalent in your framework) by function/method, nest for variants

## Patterns

### Naming
```js
// GOOD — describes the expected behavior
it('should return 401 when token is expired')
it('should create an item and return 201')

// BAD — describes the implementation
it('calls prisma.item.create')
it('works correctly')
```

### AAA Pattern
Every test follows Arrange → Act → Assert:
```js
it('should return the item by id', async () => {
  // Arrange
  const item = await createTestItem();

  // Act
  const res = await request(app).get(`/api/items/${item.id}`);

  // Assert
  expect(res.status).toBe(200);
  expect(res.body.name).toBe(item.name);
});
```

### Test isolation
- Each test is independent — no shared mutable state between tests
- Use `beforeEach` for setup, `afterEach` for cleanup
- Database tests: use transactions that rollback, or truncate tables

## Anti-patterns
- ❌ Testing implementation details (internal function calls, state shape)
- ❌ Snapshot tests for dynamic data
- ❌ `test.skip` or `test.todo` left indefinitely — either fix or delete
- ❌ Mocking everything — integration tests with real DB are more valuable
- ❌ No assertions in a test (test passes but verifies nothing)
