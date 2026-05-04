# Open a pull request
# Usage: /pr

Orchestrates the mechanical PR-creation flow end-to-end: commit any pending work, push the branch, open the PR. Each step is delegated to a Haiku worker sub-agent so the reasoning model is not billed for grunt work.

## Pre-checks

1. `git branch --show-current` — must not be `main` or `master`. If it is, stop and tell the user to switch to a feature branch.
2. `git status --porcelain` — note whether the working tree has uncommitted changes.
3. `git log @{u}..HEAD 2>/dev/null` — note whether the local branch is ahead of upstream, or has no upstream yet.

## Flow

### 1. Commit pending work (only if the working tree is non-empty)

- Stage explicitly with `git add <files>` — never `git add .` or `git add -A`. Sensitive files (`.env`, `credentials.json`, anything matching the project's `.gitignore` patterns) must not slip in.
- Delegate to the **`commit-writer`** sub-agent (Haiku) to draft and create the commit. Pass nothing — it reads the staged diff itself.
- If `commit-writer` stops with an ambiguity report (mixed types, oversized diff, hook failure), surface the report to the user and halt the command.

### 2. Push the branch

- If no upstream is set: `git push -u origin HEAD`.
- Otherwise: `git push`.
- If the push is rejected for non-fast-forward, stop. Do not force-push, do not `--force-with-lease` without explicit user authorization.

### 3. Open the PR

- Delegate to the **`pr-creator`** sub-agent (Haiku). It reads the diff against the default branch, drafts the title and body, and runs `gh pr create`.
- Return the PR URL it prints.

## Rules

- Never use destructive operations (`--force`, `--force-with-lease`, `git reset --hard`, branch deletion).
- Never skip hooks (`--no-verify`).
- The reasoning model orchestrates — it does not draft commit messages or PR bodies itself. Always delegate.
- If any step fails, stop and report. Do not retry the same operation, do not swap a sub-agent for a manual implementation.

## Why this command exists

Drafting commit messages, formatting PR bodies, and running `gh` does not require the reasoning model. By delegating each step to Haiku workers, this command runs at a fraction of the cost of a single reasoning-model invocation doing the same work end-to-end. See `examples/cost-comparison/` for measured numbers on a real project (populated after the first run).
