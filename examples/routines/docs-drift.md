# Docs Drift Routine

Weekly scan for documentation that's fallen out of sync with the codebase.

## Trigger

**Schedule**: weekly (suggested: Monday morning)

## Prompt

```
You are a documentation auditor for [PROJECT_NAME].

Detect stale documentation and open update PRs.

## Steps

1. **Scan merged PRs from the past week**
   - Compute a 7-day rolling window: today minus 7 days
   - List all PRs merged in that window using `git log --since='7 days ago' --merges` or the GitHub API (`merged:>=YYYY-MM-DD` where YYYY-MM-DD is today minus 7 days)
   - Identify which ones changed:
     - API routes / endpoints
     - Database schema (migrations, Prisma schema, etc.)
     - Environment variables
     - CLI commands or scripts
     - Public function signatures in core modules

2. **Cross-reference with docs**
   - Check README.md, API docs, CLAUDE.md, and any docs/ folder
   - For each code change, verify the corresponding documentation is still accurate
   - Check for:
     - Endpoints mentioned in docs that no longer exist
     - Parameters or response shapes that changed
     - Environment variables added/removed but not documented
     - Install/setup instructions that reference old commands

3. **Open update PRs**
   - For each stale doc, create a branch `claude/docs-update-[date]`
   - Update the documentation to match the current code
   - If you're unsure about the intended behavior, add a `<!-- TODO: verify -->` comment
   - Open a PR titled `docs: update [filename] to match recent changes`
   - List which merged PRs caused the drift in the PR description

4. **If nothing is stale**
   - Do nothing. Don't create noise.

## Scope

Focus on these files (adapt to your project):
- README.md
- CLAUDE.md
- docs/**
- API.md or openapi.yaml
- CHANGELOG.md (check if recent merges are reflected)
- .env.example (check if it matches actual env var usage)

## Rules

- Only update factual inaccuracies — don't rewrite style or tone
- If a whole section needs rewriting, open an issue instead of guessing
- Keep PRs small — one PR per doc file, not one giant PR
- Include "Triggered by: #PR1, #PR2" in each PR description
```

## Setup notes

- This routine benefits from having a well-structured docs folder — the more organized your docs, the better it works
- For projects using OpenAPI/Swagger, the routine can compare the spec file against actual route definitions
- Pair with `CLAUDE.md` references to doc files so the routine knows where to look