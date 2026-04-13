# Test workflow
# Usage: /test [scope]
# Scope: all (default), backend, frontend, coverage

Run the test suite with optional coverage report.

## Default (all)

1. Run the project's test command (check `package.json` scripts, `Makefile`, or CI config for the correct command).
2. Report: total tests, passed, failed, skipped.

## With coverage

1. Run the project's test command with its coverage flag (e.g. `--coverage`, `-- --cov`, `cargo tarpaulin` — whichever the project uses).
2. Parse coverage output — report:
   - Lines covered %
   - Branches covered %
   - Uncovered files (list the top 10 least-covered)
3. If coverage < 70%, flag it as a warning.

## On failure

- Show the full error output for failed tests.
- Identify the file and test name.
- If a test fails, read the error message and the failing test file. Identify whether the failure is in the test itself (wrong assertion, stale snapshot) or in the source code. Suggest a fix for the most likely cause.
- Do NOT auto-fix — ask before changing test files.
