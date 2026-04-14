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
   - Do NOT exceed 80 lines total — if CLAUDE.md is already at or near 80 lines, remove the oldest stale gotcha (or the least load-bearing bullet in Conventions/Structure) before adding a new one. Prefer pruning over append-only growth.
   - If nothing relevant changed for a section, leave it as-is

3. **Show changes**
   - Display the CLAUDE.md diff with `git diff CLAUDE.md`
   - If there are no changes, say so and exit cleanly
   - If there are changes, ask: "CLAUDE.md has been updated. Options: (A) stage only, (B) skip"
   - Option A: `git add CLAUDE.md` — leaves it staged so the user commits it alongside their next real commit
   - Option B: leave unstaged
   - If the user wants to commit CLAUDE.md on its own, they can run `git add CLAUDE.md && git commit` themselves with a message of their choosing.

## Rules
- Never invent information. Only document what actually happened in this session.
- If nothing changed that affects CLAUDE.md, say so and exit cleanly.
- Keep it fast — this should take under 30 seconds.
- `/wrap` never creates a commit on its own. Session-boundary commits clutter history — the update rides along with the user's next real commit.
