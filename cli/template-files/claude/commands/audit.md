# Audit workflow
# Usage: /audit

Run a full quality audit on the codebase. Combines code review, security check, and convention compliance.

<!-- Configure these paths for your project -->
<!-- BACKEND_DIR: backend/ -->
<!-- FRONTEND_DIR: frontend/ -->
<!-- SCHEMA_PATH: prisma/schema.prisma -->

> Edit the paths above to match your project structure. The steps below reference them as placeholders.

## Steps

1. **Security scan**
   - Run the project's dependency audit (e.g. `npm audit --audit-level=high`, `pip-audit`, `cargo audit`) inside `BACKEND_DIR`.
   - Check for hardcoded secret assignments — patterns where a sensitive key name is assigned a literal value of 8+ characters:
     ```bash
     grep -rE "(SECRET|PASSWORD|API_KEY|TOKEN|PRIVATE_KEY)\s*=\s*['\"][^'\"]{8,}" \
       --include="*.js" --include="*.ts" --include="*.py" \
       --include="*.env*" . 2>/dev/null \
       | grep -v "\.example" | grep -v "\.test\." | grep -v "\.spec\."
     ```
     Flag any match that is not an environment variable reference (i.e. not `process.env.*` or `os.environ*`).
   - Review auth/JWT implementation in the auth middleware.
   - Check CORS, security headers, and rate limiting config.

2. **Code quality**
   - Run the project's linter (check `package.json` scripts, `Makefile`, or CI config) and report errors.
   - Find oversized files (e.g. source files > 300 lines) and flag candidates for extraction.
   - Check that controllers/routes don't import data-layer code directly (should go through services).
   - Check for debug output (`console.log`, `print`, `dbg!`) in non-test files.

3. **Database**
   - Review `SCHEMA_PATH` for missing indexes, missing timestamps, inconsistent naming.
   - Check for N+1 patterns: find single-row queries inside loops.
   - Verify seed/fixture scripts are idempotent.

4. **Report**
   - Output a summary table: category | issues found | severity
   - List each issue with file, line, fix suggestion
   - Propose GitHub issues for P0 and P1 items
