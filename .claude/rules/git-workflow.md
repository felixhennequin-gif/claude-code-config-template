---
name: git-workflow
description: Human-in-the-loop rules for git operations that land code on shared branches. Loaded unconditionally — applies to every session.
---

# Git workflow rules

## Never merge on the user's behalf

- **Do not run `gh pr merge`, `git merge`, or any fast-forward onto `main` / `master`** unless the user has explicitly said "merge it now" **after** the PR exists.
- When asked to "create a PR and merge", "ship it", or any similar phrasing, interpret it as **create the PR only**. Push the branch, open the PR, return the URL, then stop.
- The user is the merge gate. Always leave the final click to them.

## Never force-push to shared branches

- Never `git push --force` (or `-f`) to `main` / `master` / any branch someone else might be based on.
- `--force-with-lease` on your own feature branch is fine when rebasing — but confirm first if the branch has an open PR with review comments.

## Never skip verification

- Do not use `--no-verify` on commits or pushes. If a hook fails, fix the underlying issue.
- Do not use `--no-gpg-sign` or bypass signing unless the user explicitly asks.

## Destructive operations require confirmation

- `git reset --hard`, `git clean -fd`, `git branch -D`, `git checkout -- .` — ask before running, even on a feature branch. The user may have uncommitted work you can't see.
