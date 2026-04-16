# Audit workflow
# Usage: /audit

Run a full quality audit on the codebase. Combines code review, security check, and convention compliance.

**Rule: never presume.** If something can't be verified from the code, flag it as "needs manual check" — don't write "presumed" in the report.

## Steps

1. **Security scan**
   - Inspect `package.json`, `pyproject.toml`, `Cargo.toml`, or `go.mod` to identify the language and find the backend directory. Run the appropriate dependency audit (`npm audit --audit-level=high`, `pip-audit`, `cargo audit`, `govulncheck ./...`) from that directory.
   - Check for hardcoded secret assignments — patterns where a sensitive key name is assigned a literal value of 8+ characters:
```bash
     grep -rE "(SECRET|PASSWORD|API_KEY|TOKEN|PRIVATE_KEY)\s*=\s*['\"\`][^'\"\`]{8,}" \
       --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.py" \
       --include=".env" --include="*.env*" \
       --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=build \
       . 2>/dev/null \
       | grep -v "\.example" | grep -v "\.test\." | grep -v "\.spec\."
```
     `--include=".env"` and `--include="*.env*"` are listed separately on purpose: the former guarantees the plain `.env` file is scanned, the latter covers `.env.local`, `.env.production`, `app.env`, etc.
     Flag any match that is not an environment variable reference (i.e. not `process.env.*` or `os.environ*`).
   - Review auth/JWT implementation in the auth middleware.
   - Check security headers (helmet or equivalent) and rate limiting config on auth + global routes.

2. **API surface**
   - **Input validation**: grep for `req.body`, `req.query`, `req.params` access. Flag any route handler that reads client input without passing it through a validator (Zod, Joi, Yup, class-validator, Pydantic, etc.).
   - **Cookies**: grep for `res.cookie(` — verify every call sets `httpOnly: true`, `secure` (in prod), and `sameSite`. Read the actual code, don't presume.
   - **CORS**: flag `origin: '*'` or `origin: true` combined with `credentials: true`. Flag missing origin allowlist in production config.
   - **Env vars**: find all `process.env.X` / `os.environ['X']` reads. Flag any that don't either (a) have a safe default for non-secret config, or (b) throw at startup if missing. Hardcoded fallbacks for secrets (e.g. `|| "dev-secret"`) are P0.
   - **Async error handling**: in Express projects, check the version. If Express < 5, flag async route handlers without `asyncHandler` wrapper or explicit try/catch — unhandled rejections crash the process.

3. **Code quality**
   - Run the project's linter (check `package.json` scripts, `Makefile`, or CI config) and report errors.
   - Find source files > 300 lines AND flag only those with high complexity (nested conditionals, long functions). A 500-line constants file is not a problem. If ESLint `complexity` rule is available, use it.
   - Check for debug output (`console.log`, `print`, `dbg!`) in non-test files.
   - Controllers importing data-layer code: flag **only** if the controller contains > 50 lines of query logic that would benefit from extraction. Don't flag trivial CRUD.
   - **Test coverage**: report test count and coverage if tooling exists (`npm test -- --coverage`, `pytest --cov`, `cargo tarpaulin`). Flag controllers/routes with zero tests.

4. **Database**
   - Locate the schema file (e.g. `prisma/schema.prisma`, `db/schema.rb`, `alembic/versions/`, `db/migrations/`) and review it for missing indexes, missing timestamps, inconsistent naming.
   - **Before flagging missing Prisma `@@index`**: check migration files or run `psql -c "\d+ <table>"` to confirm Postgres indexes don't already exist — Prisma auto-creates some FK indexes.
   - Check for N+1 patterns: find single-row queries (`create`, `findUnique`, `update`) inside loops. Suggest `createMany` / batch equivalents.
   - Verify seed/fixture scripts are idempotent or guarded against running in production.

5. **Report**
   - Output a summary table: category | issues found | severity
   - List each issue with file, line, fix suggestion
   - For anything that couldn't be fully verified, write "needs manual check" explicitly — never "presumed"
   - Propose GitHub issues for P0 and P1 items only
