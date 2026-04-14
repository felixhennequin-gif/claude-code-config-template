---
name: git-workflow
description: Git branching, commit, and PR conventions. Activates when creating a branch, writing a commit message, opening a pull request, resolving merge conflicts, or reviewing git history.
---

# Git workflow

Language-agnostic conventions for branches, commits, and PRs. Applies to any project regardless of stack.

## 1. Branch naming

- `feat/<short-name>` — new user-facing feature
- `fix/<short-name>` — bug fix
- `docs/<short-name>` — docs-only change
- `chore/<short-name>` — build, CI, tooling, dependency bump
- `refactor/<short-name>` — no behavior change, internal restructure

Keep the short name kebab-case, ≤ 4 words, descriptive. `feat/user-profile-page`, not `feat/stuff` or `feat/UserProfilePage`.

Never commit directly to `main` or `master` — the PreToolUse hook in `.claude/settings.json` blocks edits on those branches precisely so this rule doesn't rely on memory.

## 2. Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <summary>

<body explaining the why, not the what>
```

- **type**: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`, `style`, `build`, `ci`
- **scope** (optional): the area of the codebase — `auth`, `checkout`, `ci`, `prisma`
- **summary**: imperative mood, lowercase, no trailing period, ≤ 72 chars
- **body**: explains *why* the change was made. The diff shows *what*.

```text
BAD:
  updated file
  fixed the thing
  WIP

GOOD:
  fix(auth): reject expired refresh tokens before issuing new ones

  The refresh endpoint was accepting any structurally valid token,
  including ones past their TTL. Production incident #1423 traced
  a session resurrection bug to this gap.
```

**One logical change per commit.** Don't bundle a bug fix with an unrelated refactor — reviewers can't cleanly revert one without the other, and `git bisect` becomes useless.

## 3. Rebasing vs. merging

- **Feature branches**: rebase onto `main`/`master` to keep history linear (`git pull --rebase origin main`).
- **Shared branches** (that another person has already pulled): never rewrite history. Use `git merge` instead.
- **Rule of thumb**: if nobody else has pulled your branch, rebase is safe. If they have, merge is safer.

## 4. Pull requests

A good PR answers three questions in the description:

1. **Why** is this change needed? (one paragraph, link the issue or incident)
2. **What** did you change at a high level? (3–5 bullets, not a file list)
3. **How** do reviewers verify it? (test plan, manual repro, screenshots for UI)

Keep PRs under ~400 lines of diff when possible. Large PRs get rubber-stamped because nobody has the energy to review them carefully. If a change genuinely requires more, split it into stacked PRs.

## 5. Merge conflicts

Resolve conflicts by understanding both sides, not by picking the one you wrote. Read the incoming change, read your change, decide what the merged behavior should be. If either side is unclear, stop and ask the author.

After resolving, run the test suite and the linter before finishing the merge — a conflict resolution that compiles is not automatically correct.

## Anti-patterns

- ❌ `git commit -m "wip"`, `"fix"`, `"more"` — commit messages without content
- ❌ Force-pushing to a shared branch — use `--force-with-lease` at minimum, or merge instead
- ❌ Merging your own PR without review (unless the project explicitly allows it for trivial changes)
- ❌ Squashing a rebase-in-progress — finish the rebase, then squash in a second step
- ❌ `git commit --amend` on a commit that's already pushed to a shared branch
- ❌ Bundling unrelated changes in one commit "to save time" — it costs reviewers more time than it saves you
- ❌ Leaving merge markers (`<<<<<<<`, `=======`, `>>>>>>>`) in a commit — hooks and CI should block this, but double-check before pushing

## If the project has a `CONTRIBUTING.md`, that document wins

This skill sets a reasonable default. If the project's `CONTRIBUTING.md` specifies a different branching model (trunk-based, GitFlow, release branches) or different commit conventions (Angular style, Gitmoji), follow that instead. Skills are defaults; project rules are authoritative.
