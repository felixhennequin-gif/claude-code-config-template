# Wrap-up workflow
# Usage: /wrap

End-of-session update. Updates CLAUDE.md with what changed during this session,
then proposes a commit.

## Steps

1. **Summarize the session**
   - Run `git diff --stat HEAD` to see what files changed
   - Run `git log --oneline -5` to see recent commits
   - Identify: what was added, fixed, or refactored during this session

2. **Update CLAUDE.md**
   - Read the current CLAUDE.md
   - Update only the sections that reflect what changed:
     - Stack versions if a dependency was added or upgraded
     - Structure if new directories or files were created
     - Commands if new scripts were added to package.json
     - Conventions if a new pattern was established during the session
     - Gotchas if a non-obvious issue was discovered and fixed
   - Do NOT rewrite sections that didn't change
   - Do NOT exceed 80 lines total
   - If nothing relevant changed for a section, leave it as-is

3. **Show changes**
   - Display the CLAUDE.md diff with `git diff CLAUDE.md`
   - If there are no changes, say so and exit cleanly
   - If there are changes, ask: "CLAUDE.md has been updated. Options: (1) commit now, (2) stage only, (3) skip"
   - Option 1: `git add CLAUDE.md && git commit -m "docs: update CLAUDE.md post-session"`
   - Option 2: `git add CLAUDE.md` — leaves it staged for the user to commit with their next real commit
   - Option 3: leave unstaged

## Rules
- Never invent information. Only document what actually happened in this session.
- If nothing changed that affects CLAUDE.md, say so and exit cleanly.
- Keep it fast — this should take under 30 seconds.
- Most teams prefer not to have session-boundary commits in their history — default to option 2 (stage) if the user doesn't specify a preference.
