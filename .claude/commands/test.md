# Test workflow
# Usage: /test [scope]
# Scope: all (default), backend, frontend, coverage

Run the test suite with optional coverage report.

## Default (all)

1. `cd backend && npm test`
2. `cd frontend && npm test` (if test script exists)
3. Report: total tests, passed, failed, skipped

## With coverage

1. `cd backend && npm test -- --coverage`
2. Parse coverage output — report:
   - Lines covered %
   - Branches covered %
   - Uncovered files (list the top 10 least-covered)
3. If coverage < 70%, flag it as a warning

## On failure

- Show the full error output for failed tests
- Identify the file and test name
- Suggest a likely fix based on the error message
- Do NOT auto-fix — ask before changing test files
