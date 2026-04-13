---
name: coding-principles
description: Core behavioral rules for any coding task — think before coding, simplicity first, surgical changes, goal-driven execution. Activates on every feature, fix, refactor, or code edit, regardless of stack.
allowed-tools: Read, Grep, Glob
---

<!-- Adapted from Andrej Karpathy's observations on LLM coding pitfalls,
     via forrestchang/andrej-karpathy-skills. Credit to the original author. -->

# Coding principles

Four rules that apply to every code change in this repo, regardless of stack.
Stack-specific conventions live in `express-api`, `prisma-patterns`,
`react-frontend`, and `.claude/rules/test-files.md` — this skill is about
*how* to change code, not *what* to write inside each framework.

## 1. Think before coding

- State assumptions explicitly. If the request is ambiguous, name the
  ambiguity and ask — don't pick silently.
- Surface tradeoffs (performance vs. simplicity, safety vs. velocity)
  before implementing, not after.
- If you're confused about a file, a constraint, or an existing pattern,
  stop and ask — don't guess.

**Test:** Could the user point at your diff and say "I didn't ask for that
interpretation"? If yes, you assumed instead of asking.

## 2. Simplicity first

- Write the minimum code that solves the stated problem.
- No speculative flexibility, no abstractions for single-use code, no
  error handling for scenarios that can't happen.
- If 200 lines could be 50, rewrite it.

**Test:** Would a senior engineer reviewing this say it's overcomplicated?
If yes, simplify before shipping.

## 3. Surgical changes

- Touch only what the task requires. Don't "improve" adjacent code,
  comments, imports, or formatting on the way past.
- Match the existing style, even if you'd do it differently.
- Remove only the imports/variables your own changes orphaned. Pre-existing
  dead code: mention it, don't delete it unless asked.

**Test:** Can every changed line be traced back to a concrete user
requirement? If not, revert the line.

## 4. Goal-driven execution

Transform imperative tasks into verifiable goals before starting:

| Instead of...     | Transform to...                                              |
|-------------------|--------------------------------------------------------------|
| "Add validation"  | "Write Vitest cases for invalid input, then make them pass"  |
| "Fix the bug"     | "Write a failing test that reproduces it, then make it green"|
| "Refactor X"      | "Run the test suite before and after — must stay green"     |
| "Make it faster"  | "Define the baseline metric and the target, then measure"    |

For multi-step work, state a short plan with per-step verification:

```
1. [step] → verify: [concrete check]
2. [step] → verify: [concrete check]
```

**Test:** If the user walked away and came back, could they tell whether
the task is done by running a single command? If not, the success criterion
is too vague — sharpen it first.

## Scope

These rules bias toward caution over speed. Trivial edits (typo fixes,
obvious one-liners) don't need the full rigor — use judgment.

For stack-specific conventions, see `.claude/skills/express-api/`,
`.claude/skills/prisma-patterns/`, `.claude/skills/react-frontend/`,
and `.claude/rules/test-files.md`.
