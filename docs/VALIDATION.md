# Real-world validation

This template has been tested on real projects to verify that its conventions, hooks, and skills produce measurably different Claude Code behavior compared to a bare setup.

## Test methodology

For each project, we:
1. Ran a Claude Code session **without** the template (bare `CLAUDE.md` or none)
2. Installed the template and ran the **same tasks** again
3. Compared: session context time, convention adherence, errors caught by hooks

## Project 1: Node.js REST API (Express + Prisma + React)

<!-- TODO: Replace with actual results from testing on cocktail-app / Écume -->

- **Stack**: Node.js 22, Express 5, Prisma 7, PostgreSQL, React 19, Tailwind v4
- **Tasks tested**: "Add a new API endpoint with validation", "Fix a failing test", "Refactor a 300-line controller"
- **Without template**: [time to first useful output, conventions missed, errors]
- **With template**: [time to first useful output, conventions followed, errors caught by hooks]
- **Key difference**: [what changed most — e.g. "Claude stopped wrapping Express 5 controllers in try/catch"]

## Project 2: [Different stack]

<!-- TODO: Test on a non-Node project (Go, Python, or Rust) -->

- **Stack**: [to be filled]
- **Tasks tested**: [to be filled]
- **Result**: [to be filled]

## What we learned

<!-- TODO: Fill after testing -->

- The hooks (branch guard, bash safety, lint-on-edit) provided the most consistent value — they work regardless of skill quality
- Skills were most useful for [specific pattern]
- The debugging skill prevented [specific failure mode]
- We had to customize [what] for project-specific needs

## What broke

<!-- TODO: Be honest about failures -->

- [Any skill that gave bad advice]
- [Any hook that caused friction]
- [Any convention that conflicted with the real project]
