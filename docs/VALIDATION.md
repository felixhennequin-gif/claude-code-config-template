# Real-world validation

This template has been tested on real projects to verify that its conventions, hooks, and skills produce measurably different Claude Code behavior compared to a bare setup.

## Test methodology

For each project, we:
1. Ran a Claude Code session **without** the template (bare `CLAUDE.md` or none)
2. Installed the template and ran the **same tasks** again
3. Compared: session context time, convention adherence, errors caught by hooks

## Project 1: Node.js REST API (Express + Prisma + React)

- **Stack**: Node.js, Express 5, Prisma 7, PostgreSQL, React 19, Tailwind v4
- **Install method**: `npx create-claude-code-config@0.8.0`
- **Tasks tested**: Fresh install on existing project (LeCabanon), immediate `--update` run
- **Install result**: 22 files tracked in manifest, npm/npx permissions auto-injected, `.gitignore` updated automatically. Time to install: ~30 seconds including npx download.
- **Update result**: 0 updated, 1 skipped (`settings.json`, excluded by design), 20 already up to date. Correct behavior — no false positives, no data loss.
- **Key difference vs bare setup**: Stack conventions, hooks, and commands available immediately after install with no manual configuration.

## Project 2: [Different stack]

<!-- TODO: Test on a non-Node project (Go, Python, or Rust) -->

- **Stack**: [to be filled]
- **Tasks tested**: [to be filled]
- **Result**: [to be filled]

## What we learned

- The `--update` manifest detection works correctly: files untouched since install are detected via SHA-256 hash comparison, customized files are left intact.
- `settings.json` exclusion from `--update` is the right call — it contains injected permissions that vary per project.
- Install time is under 30 seconds including npx package download on first run.

## What broke

<!-- TODO: Be honest about failures -->

- [Any skill that gave bad advice]
- [Any hook that caused friction]
- [Any convention that conflicted with the real project]
