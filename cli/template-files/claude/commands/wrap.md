# Session wrap workflow
# Usage: /wrap

Analyse the session and propose improvements to the project's Claude config. Writes a reviewable checklist to `~/.claude/template-proposals/`. Touches nothing else.

**Rule: no findings, no file.** If the session produced nothing worth proposing, say so and stop — do not invent proposals to fill the page.

**Rule: ask before writing.** The three follow-up questions are mandatory, not optional polish. User input is a first-class signal alongside session analysis.

## Steps

1. **Detect the project.** `basename $(pwd)` slugified (lowercase, non-alphanumerics → `-`). Used for the output filename.

2. **Scan the session.** Apply the four detectors from `.claude/skills/core/session-wrap/SKILL.md`:
   - A: friction observed (agent reminded/corrected ≥ 2× on the same thing)
   - B: missing rule (a convention rejected that no existing skill covers)
   - C: reusable pattern (a workflow emerged that could help future sessions)
   - D: imperfect command/skill (an existing one was used and fell short)

3. **Ask the user three questions.** One per line, short, no preamble:
   - "Friction I missed during this session?"
   - "Workflow we invented here worth making reusable?"
   - "Command or skill that didn't behave as expected?"

   Wait for answers. Do not proceed without them.

4. **Filter findings into proposals.** Drop anything that:
   - Targets a file outside `.claude/**`, `CLAUDE.md`, `CLAUDE.local.md`, or `CHANGELOG.md`
   - Duplicates a rule already present in the current `.claude/` tree (diff before writing)
   - Has no concrete diff ready to apply
   - Is business-specific to this project but framed as reusable — route to `CLAUDE.md`, not to a skill

5. **Write the output file.** Path: `~/.claude/template-proposals/YYYY-MM-DDTHHMM-<slug>.md`. Format per `.claude/skills/core/session-wrap/SKILL.md` — strict, each proposal a `[ ]` block with target, category, why, diff, CHANGELOG entry.

6. **Report.** Print the absolute path of the file and N proposals / M filtered-out. Stop.

## Never

- Never modify anything outside `~/.claude/template-proposals/`.
- Never run `/wrap-apply` automatically afterwards.
- Never target code files, tests, or project config unrelated to Claude.
- Never propose a change to the upstream template repository. This is strictly local.