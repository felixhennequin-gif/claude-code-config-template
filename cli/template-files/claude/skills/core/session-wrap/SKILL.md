---
name: session-wrap
description: End-of-session workflow. Analyses the session and proposes improvements to the project's Claude config as a reviewable checklist, then applies the user-approved subset. Activates on /wrap and /wrap-apply, and on phrases like "wrap up the session" or "propose config improvements".
last-verified: 2026-04-17
---

# session-wrap

End-of-session self-improvement loop for the **project's own** `.claude/` config. Two commands, two phases:

- `/wrap` → analyse, propose, write a checklist to `~/.claude/template-proposals/`
- `/wrap-apply <path>` → apply the `[x]`-checked proposals from that file

Nothing auto-commits. Nothing touches the upstream template repo. Nothing outside `.claude/`, `CLAUDE.md`, `CLAUDE.local.md`, and the project `CHANGELOG.md` is ever edited.

## Rules

1. **The user triggers `/wrap` deliberately.** No session-end detection, no hook. The agent doesn't know when a session ends; the user does.
2. **Proposals are actionable or they don't exist.** Every proposal ships with a concrete target file and a unified diff ready to apply. "Improve error handling" is not a proposal; a diff adding three rules to `banned-patterns.md` is.
3. **Scope is the local `.claude/` config.** Code files, tests, build configs, CI — all out of scope. If a finding suggests a code change, it's a different workflow (`/audit`, `/code-review`).
4. **Filter aggressively.** Five weak proposals beat one strong one, in reverse. Drop anything that duplicates existing rules, lacks a diff, or is business-domain-specific masquerading as reusable.
5. **`/wrap-apply` is all-or-nothing per proposal.** A proposal either lands cleanly or is skipped whole. Never partial-patch. Never auto-resolve conflicts.
6. **The wrap file is self-documenting.** After apply, checked proposals become `[applied YYYY-MM-DD]`. The file remains as an audit trail — the user can re-read it months later to understand when each rule landed.

## Four detectors

Scan the session history for these signals. Each signal is a **finding**. Findings become **proposals** only after filtering (see below).

| Detector | Signal | Example target |
|---|---|---|
| **A — friction** | User reminded/corrected the agent ≥ 2× on the same thing | Add a note to the relevant skill |
| **B — missing rule** | A convention was rejected that no existing skill/rule covers | Add to `CLAUDE.md` or the matching skill |
| **C — reusable pattern** | A workflow emerged that could help future sessions | New command or new skill |
| **D — imperfect command/skill** | An existing one was used and fell short | Patch the existing file |

## The three questions

Always ask these before writing the file. User input is a signal, not polish.

```
Friction I missed during this session?
Workflow we invented here worth making reusable?
Command or skill that didn't behave as expected?
```

Wait for answers. No defaults, no assumptions.

## Filtering — drop a finding if

- Target is outside `.claude/**`, `CLAUDE.md`, `CLAUDE.local.md`, or `CHANGELOG.md`
- The same rule already exists in the current `.claude/` tree (diff against current state before writing)
- No concrete diff can be written (finding is too vague)
- Business-domain-specific framed as reusable (reroute to `CLAUDE.md`, don't drop)
- Based on a single ambiguous event with no clear fix

## Output file — strict format

Path: `~/.claude/template-proposals/YYYY-MM-DDTHHMM-<project-slug>.md`

```markdown
# Session wrap — <project-slug> — <human date>

## Session log

<2-5 sentences, prose, factual. What was worked on, decided, shipped. No adjectives, no narrative arc.>

## Proposals

### [ ] Proposal 1 — <imperative-mood title>

**Category:** <A | B | C | D>
**Target:** `<path from project root>`

**Why:** <1-2 sentences tying this to what happened in the session.>

**Diff:**

​```diff
<unified diff, 3 context lines, ready to apply>
​```

**CHANGELOG entry:**

​```markdown
### <Added | Changed | Fixed>
- <one-line Keep a Changelog entry>
​```

---

### [ ] Proposal 2 — ...

## Optional — update project CHANGELOG

### [ ] Proposal N — Record this session's config changes in CHANGELOG.md

**Category:** housekeeping
**Target:** `CHANGELOG.md`

**Why:** Keep a trace of when each config change landed.

**Diff:** (regenerated at apply time from the actually-accepted proposals above)

## Filtered out

- <finding> — <reason>

## Metadata

- Generated: <ISO timestamp>
- Project: <slug>
- Cwd: <absolute path>
```

## GOOD vs BAD proposals

```diff
# BAD — vague, no target, no diff
### [ ] Proposal — Improve error handling
**Why:** Error handling was inconsistent during the session.

# GOOD — specific, concrete, drop-in
### [ ] Proposal — Forbid bare Error throws in service layer
**Target:** `.claude/skills/core/error-handling/SKILL.md`
**Why:** Agent threw `new Error('...')` 3× in service code; project convention is typed errors.
**Diff:**
​```diff
+## Service layer
+- Never `throw new Error(...)` — use a typed error (`NotFoundError`, `ValidationError`, etc.)
+- Bare Error loses stack context and defeats the error taxonomy in `errors/`.
​```
```

```diff
# BAD — out of scope
### [ ] Proposal — Refactor the auth controller
**Target:** `backend/src/controllers/auth.ts`

# GOOD — same insight, correct scope
### [ ] Proposal — Document controller-vs-service boundary for auth
**Target:** `.claude/skills/stacks/express-api/SKILL.md`
**Why:** Session showed auth controller absorbing 200 lines of service logic. Skill should flag this.
```

```diff
# BAD — business-specific, framed as reusable
### [ ] Proposal — Add community membership gating rule to coding-principles skill
**Target:** `.claude/skills/core/coding-principles/SKILL.md`

# GOOD — same rule, routed to the right file
### [ ] Proposal — Document LeCabanon's community membership gating rule in CLAUDE.md
**Target:** `CLAUDE.md`
```

## `/wrap-apply` — flow

1. Locate file (argument or picker from 5 most recent).
2. Parse proposals. Only `[x]` count.
3. Validate each: scope allowlist, target exists (if modify), no context drift.
4. Apply clean proposals. All-or-nothing per proposal.
5. Regenerate CHANGELOG entry from actually-applied proposals (not from the original full list).
6. Mark wrap file: `[x]` → `[applied YYYY-MM-DD]` on success; skipped `[x]` gets a `<!-- skipped: reason -->` comment.
7. Report: applied N, skipped M, files touched. Stop. Don't commit.

## Anti-patterns

- ❌ Writing the output file without asking the three questions — user input is part of detection
- ❌ Proposing a new skill when a one-line addition to an existing skill would do
- ❌ "Proposal — improve X" with no diff — if there's no diff, there's no proposal
- ❌ Duplicating a rule already in `.claude/` — always diff against current state before writing
- ❌ Generating a big wrap file "just in case" — quality over quantity, zero proposals is a valid outcome
- ❌ Running `/wrap-apply` on a file the user hasn't opened and checked — always confirm the path
- ❌ Partial-applying a diff that drifted — skip whole, report, let the user resolve manually
- ❌ Committing after apply — the user decides what lands in git, always
- ❌ Editorialising the session log with adjectives ("successful", "productive", "great work") — the log is factual

## Helper script

`scripts/wrap-dedup-check.sh <wrap-file.md>` — for each proposal in the given wrap file, greps the target file for the proposed `+` lines. Prints any line that already exists verbatim in the target, so the user can drop the duplicate before review. Optional but useful — wire it into a pre-review sanity check if you find yourself rejecting duplicate proposals often.

## References

- Keep a Changelog: https://keepachangelog.com/en/1.1.0/
- Anthropic skills convention: https://docs.claude.com/en/docs/claude-code/skills

## Examples

See `EXAMPLES.md` in this skill directory — three calibrated proposals (categories A, C, D) plus three counter-examples that would be filtered out.