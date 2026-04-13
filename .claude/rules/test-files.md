---
description: Rules for test files. Loaded only when working with files matching *.test.* or *.spec.* patterns.
globs: ["**/*.test.*", "**/*.spec.*", "**/tests/**", "**/__tests__/**"]
---

# Test file conventions

## Framework
- Vitest for backend and frontend unit tests
- Supertest for API integration tests
- Testing Library for React component tests (if applicable)

## Structure
- Test files colocated next to source OR in a `tests/` directory — pick one per project, be consistent
- Name: `[module].test.js` or `[module].spec.js`
- Group with `describe()` by function/method, nest for variants

## Patterns

### Naming
```js
// BON — décrit le comportement attendu
it('should return 401 when token is expired')
it('should create a recipe and return 201')

// MAUVAIS — décrit l'implémentation
it('calls prisma.recipe.create')
it('works correctly')
```

### AAA Pattern
Every test follows Arrange → Act → Assert:
```js
it('should return the recipe by id', async () => {
  // Arrange
  const recipe = await createTestRecipe();

  // Act
  const res = await request(app).get(`/api/recipes/${recipe.id}`);

  // Assert
  expect(res.status).toBe(200);
  expect(res.body.name).toBe(recipe.name);
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
