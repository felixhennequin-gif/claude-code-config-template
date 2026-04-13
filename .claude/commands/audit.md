# Audit workflow
# Usage: /audit

Run a full quality audit on the codebase. Combines code review, security check, and convention compliance.

## Steps

1. **Security scan**
   - Run `cd backend && npm audit --audit-level=high`
   - Check for hardcoded secrets: `grep -r "password\|secret\|api_key\|token" --include="*.js" --include="*.ts" -l`
   - Review JWT implementation in auth middleware
   - Check CORS, Helmet, rate limiting config

2. **Code quality**
   - Run `cd backend && npm run lint` — report errors
   - Find files > 300 lines: `find backend/src -name "*.js" | xargs wc -l | sort -rn | head -20`
   - Find controllers with Prisma imports (should be in services only)
   - Check for `console.log` in non-test files

3. **Database**
   - Review `prisma/schema.prisma` for missing indexes, missing `@updatedAt`, inconsistent naming
   - Check for N+1 patterns: grep for `findUnique` inside loops
   - Verify seed is idempotent (uses `upsert`)

4. **Frontend**
   - Find components > 200 lines
   - Check for `useEffect` with missing dependencies
   - Verify all images have alt text
   - Check for hardcoded colors (should use CSS variables)

5. **Report**
   - Output a summary table: category | issues found | severity
   - List each issue with file, line, fix suggestion
   - Propose GitHub issues for P0 and P1 items
