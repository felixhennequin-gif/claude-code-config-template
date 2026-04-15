---
name: testing
description: Testing strategy and conventions. Activates when writing tests, deciding what to test, editing files under *.test.*, *.spec.*, tests/, or __tests__/, setting up a test suite, or evaluating test coverage for any language or stack.
---

# Testing

> The code snippets below use JavaScript/Jest syntax as a concrete
> example, but every rule is language-agnostic. Apply the same
> principles with `pytest`, `go test`, `cargo test`, `phpunit`, etc.
> A Python equivalent of each example is shown inline where the
> shape differs enough to matter.

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

## 3. Coverage: 70% is the floor, prod-failing cases are the goal

70% line coverage on business logic is the floor — below that, flag it.
But hitting the floor is not the point: 100% coverage does not mean the
code is correct, it only means every line was executed at least once.
The actual goal is that every case which fails in prod is covered by a
test. A suite at 100% with no edge-case assertions is also a failure.

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

```python
# Same function, pytest equivalent — same coverage shape, different syntax:
def test_parses_valid_age(): ...
def test_raises_for_negative_age(): ...
def test_raises_for_non_integer_age(): ...
def test_raises_for_age_over_150(): ...
```

## 4. Framework, structure, naming

- **Framework** — use the project's existing test runner. Don't switch frameworks without asking. Check `package.json` scripts, `Makefile`, `pyproject.toml`, or CI config for the correct test command. If no test infrastructure exists, ask the user which framework to use before creating test files.
- **Structure** — test files colocated next to source OR in a `tests/` directory. Pick one per project and stay consistent.
- **File name** — `[module].test.js` / `[module].spec.js` — adapt the extension to the project language (`.test.ts`, `test_module.py`, `_test.go`, etc.).
- **Grouping** — group with `describe()` (or the equivalent in your framework) by function/method; nest for variants.

### Naming tests by behavior, not implementation

```js
// GOOD — describes the expected behavior
it('should return 401 when token is expired')
it('should create an item and return 201')

// BAD — describes the implementation
it('calls prisma.item.create')
it('works correctly')
```

### AAA pattern (Arrange → Act → Assert)

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

- Each test is independent — no shared mutable state between tests.
- Use `beforeEach` for setup, `afterEach` for cleanup.
- Database tests: use transactions that roll back, or truncate tables between tests.

## 5. When NOT to write tests

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

## Helper scripts

- `scripts/coverage-check.sh <min-percent>` — reads coverage output from stdin (Istanbul/c8, pytest-cov, or go cover format), exits non-zero if below the threshold. Pipe your coverage command into it: `npm test -- --coverage | scripts/coverage-check.sh 80`. Makes the "coverage is a floor" rule enforceable in CI.
