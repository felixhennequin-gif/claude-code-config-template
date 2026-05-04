# Lint Claude Code config
# Usage: /lint-config

Run a full static check on the project's Claude Code configuration. Mirrors what CI does, but interactive.

## Steps

1. **settings.json**
   - Parse `.claude/settings.json` with `python3 -m json.tool` or `jq`. Report any parse error with the exact line.
   - Verify every hook referenced in `PreToolUse`, `PostToolUse`, `SessionStart`, and `Notification` points to a file that exists on disk.

2. **Hook scripts**
   - For each `.claude/hooks/*.sh`, run `bash -n` to check syntax. Report failures per file.
   - If `shellcheck` is installed, run `shellcheck -S error` on each hook as well.

3. **CLAUDE.md size**
   - Count lines in the root `CLAUDE.md`.
   - Warn (not fail) if over 80 lines — Claude Code drops context beyond that, per the root CLAUDE.md guidance.

4. **Skill cross-references**
   - Grep each skill under `.claude/skills/**/SKILL.md` for links in the form `[text](path)` or bare `.claude/skills/...` paths.
   - For each cross-reference, verify the target exists. Broken links are the #1 silent failure mode.

5. **Report**
   - Group findings by category (settings / hooks / CLAUDE.md / cross-refs).
   - For each finding, print the file and a one-line reason.
   - End with a total count. Exit `OK` if nothing found.

## Rules

- Read-only. Never edit files.
- If a tool is missing (jq, shellcheck), skip that check and log "skipped — tool not installed".
- Do not reformat or auto-fix — this command only reports.
