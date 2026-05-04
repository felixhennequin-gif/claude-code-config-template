# Skill validation
# Usage: /skill-check [path-to-skill]

Validate the SKILL.md at `$ARG` (default: all skills). Checks are purely static — never load or execute the skill.

## Steps

1. **Resolve target**
   - If `$ARG` is empty, collect every `.claude/skills/core/*/SKILL.md` and `.claude/skills/stacks/*/SKILL.md`.
   - If `$ARG` is a directory, look for `SKILL.md` inside it.
   - If `$ARG` is a file, use it directly.
   - If nothing is found, report and stop.

2. **Frontmatter fields**
   For each target file, extract the YAML frontmatter (between the first and second `---` lines) and verify:
   - `name:` is present and non-empty
   - `description:` is present and non-empty
   - `description:` is a single line (no embedded newlines) — multi-line descriptions break Claude Code's skill selector
   - `name:` matches the parent directory name (e.g. `.claude/skills/core/debugging/SKILL.md` must have `name: debugging`)

3. **Anti-patterns section**
   - Grep for a heading containing "anti-pattern", "banned", "avoid", or "don't" (case-insensitive).
   - If no such section exists, flag it — the anti-patterns section is the highest-ROI content in a skill (see root `CLAUDE.md`).

4. **Size**
   - Check the file is under 5000 tokens (`wc -w` as a proxy — ~750 words ≈ 1000 tokens, so flag above ~3750 words).
   - Skills above the limit get truncated by Claude Code.

5. **Scripts references**
   - Grep for `scripts/` references in the file body.
   - For each reference `scripts/<name>`, verify the file exists next to the SKILL.md (`<skill-dir>/scripts/<name>`).
   - Missing script references are a bug.

6. **Report**
   - One line per issue, prefixed with the file path.
   - Exit with a summary: `N skills checked, M issues found`.
   - If nothing is wrong, print `OK`.

## Rules

- Do not modify files. This is a read-only check.
- Do not rerun CI or build steps — static inspection only.
- If the user passed a path that does not exist, say so clearly.
