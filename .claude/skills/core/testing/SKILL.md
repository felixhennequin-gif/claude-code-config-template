---
name: testing
description: Testing strategy and decisions. Activates when writing tests, deciding what to test, setting up a test suite, or evaluating test coverage for any language or stack.
---

# Testing

## 1. Decide what to test first

Value hierarchy (highest to lowest ROI):
1. Integration tests against real dependencies (DB, HTTP) — catch the bugs that matter in prod
2. Unit tests for pure business logic with complex branching
3. Do not test framework glue, getters/setters, or generated code

Rule of thumb: if a test requires mocking 3+ dependencies to run, you're
testing the wrong layer. Move the test up (integration) or extract the
logic into a pure function and test that.

```js
// BAD — mocks everything, tests nothing real
it('should call prisma.user.findUnique', async () => {
  prisma.user.findUnique.mockResolvedValue({ id: '1', email: 'a@b.com' });
  const result = await getUser('1');
  expect(prisma.user.findUnique).toHaveBeenCalledWith({ where: { id: '1' } });
});

// GOOD — tests the behavior, not the implementation
it('should return null when user does not exist', async () => {
  const result = await getUser('nonexistent-id');
  expect(result).toBeNull();
});
```

## 2. Define the success criterion before implementing

Not dogmatic TDD — just: know what "done" looks like before writing code.
Write the test name (or assertion) first, even if the test body comes later.

```js
// BAD — implement first, test whatever comes out
function applyDiscount(price, code) { /* ... */ }
// test written after: mirrors implementation, not the requirement

// GOOD — define the contract first
it('should apply 20% discount for code SUMMER20')
it('should return original price for unknown codes')
it('should throw for negative prices')
// now implement applyDiscount to make these pass
```

## 3. Coverage is a floor, not a goal

100% coverage does not mean the code is correct — it means every line
was executed at least once. What matters is that the cases that fail in
prod are covered.

Mandatory cases for any non-trivial function:
- Happy path (expected input, expected output)
- Edge cases: null/undefined, empty string/array, zero, boundary values
- Error cases: invalid input, dependency failure, permission denied

```js
// For a function that parses a user age:
it('should parse valid age')           // happy path
it('should throw for negative age')    // edge case
it('should throw for non-integer age') // edge case
it('should throw for age over 150')    // boundary
```

Coverage < 70% on business logic: flag it.
Coverage = 100% with no edge case tests: also flag it.

## 4. When NOT to write tests

Skip tests for:
- One-shot migration scripts (run once, delete)
- Generated code (Prisma client, GraphQL types, OpenAPI stubs)
- Pure configuration files
- Trivial getters/setters with no logic

Do not let "we should have tests" become a reason to write tests that
test nothing. A bad test is worse than no test — it gives false confidence
and breaks on every refactor.

## Anti-patterns

- ❌ Mocking everything — if you mock the DB, you're not testing the query
- ❌ Testing implementation details (which function was called, in what order)
- ❌ Snapshot tests on dynamic data — they always go stale
- ❌ `test.skip` left indefinitely — fix it or delete it
- ❌ One giant test that asserts 15 things — split into focused tests
- ❌ Testing the framework ("does express call next()?") — it does, trust it
