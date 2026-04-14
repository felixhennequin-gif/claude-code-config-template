---
name: code-review
description: Structured workflow for acting on an external code review — triage findings by severity and effort, write a prioritized roadmap to /tmp/roadmap.md, then hand execution prompts to Claude Code batch by batch. Activates when the user receives a review, audit, or critique of their repo and wants to act on it. Also triggers on "triage this review", "make a roadmap from this feedback", "act on these findings", "we have a list of issues to fix".
---

<!-- Three phases: Analyse → Roadmap → Execute. Never collapse them into one. -->

# Code Review

Three phases that apply to every incoming review, regardless of repo or stack.

## 1. Analyse the review

Read repo context before reading the review. Open `CLAUDE.md`, `CONTRIBUTING.md`, and `CHANGELOG.md` first — they tell you which decisions are intentional and which findings are already fixed. A bug report against a documented gotcha is not a bug.

For every finding in the review, produce one row:

| # | Finding | Severity | Effort | Notes |
|---|---------|----------|--------|-------|

**Severity** — P0 (broken / release blocker), P1 (real quality issue), P2 (genuine improvement), P3 (opinion)

**Effort** — S (< 30 min), M (30 min – 2h), L (> 2h)

**Notes** — agree or disagree, with one sentence of justification. Never leave Notes blank.

**Test:** Could someone read your triage table and understand exactly what will and won't be fixed, and why? If not, your Notes column is doing too little work.

```
// BAD — silent dismissal
| 4 | bash-safety blocklist too narrow | P3 | S | — |

// GOOD — reasoned position
| 4 | bash-safety blocklist too narrow | P1 | M | Agree. Hook claims to be a safety net
|   |                                  |    |   | but misses curl|bash and SSH writes.
|   |                                  |    |   | Option A: rename to dangerous-rm-guard.sh.
|   |                                  |    |   | Option B: expand blocklist + add CI tests. |
```

**Criteria for disagreeing with a finding**
- It contradicts a decision documented in `CLAUDE.md` or `CONTRIBUTING.md`
- The fix is a breaking change whose cost exceeds the benefit
- The reviewer is confusing a scope limit with a bug
- The finding is correct in the abstract but falls outside the project's stated scope (e.g. asking for i18n in a tool explicitly documented as English-only)
- It is already addressed in `CHANGELOG.md`

## 2. Write the roadmap

Group findings into batches. One batch = one branch + one PR. Then write everything to `/tmp/roadmap.md` and stop.

**Grouping rules**
- P0 always goes first, alone or with adjacent S-effort items
- Group by file proximity — avoid two batches touching the same files
- P1 effort S before P1 effort L (quick wins before big refactors)
- P2 and P3 go last or are deferred with justification
- **Tiebreaker:** when file proximity and severity ordering conflict, file proximity wins. Merge conflicts between batches are more expensive than a delayed quick win.
- **Batch size:** aim for 3–7 checklist items per batch. Split a batch if it would produce more than ~200 LOC of diff or mix unrelated concerns.

**roadmap.md format**

```markdown
# Roadmap — [date]
Source: [review title or commit ref]

## Batch 1 — fix/[name]
**[Dominant severity] — ~[estimated duration]**
[One sentence describing what this batch achieves]

- [ ] change 1
- [ ] change 2

## Batch 2 — fix/[name]
...

## Deferred / out of scope
- [finding #N] — [one-sentence reason]
```

**Test:** Could someone open `/tmp/roadmap.md` with no conversation context and execute every batch correctly? If not, your batch descriptions are missing information.

```
// BAD — implicit, requires conversation context
## Batch 3 — fix/hooks
- [ ] Fix the hook issue we discussed

// GOOD — self-contained
## Batch 3 — fix/secret-scan-dotenv
**P1 — ~20 min**
Fix secret-scan command that misses plain .env files (no extension).

- [ ] Replace the single `*.env*` glob with two patterns: `.env` and `*.env*`
- [ ] Align the command with the stricter regex already used in CI
- [ ] If the project mirrors this file elsewhere (generated assets, packaged template, etc.), run the project's sync/build step after editing
```

After writing `/tmp/roadmap.md`, display it in the conversation and **stop**. Do not begin execution without an explicit "go".

## 3. Execute

Once the roadmap is validated, hand these prompts to Claude Code.

**Prompt — execute batches**

```
Read /tmp/roadmap.md before doing anything else.

Execute the batches in order. For each batch:
1. git checkout -b <branch-name>
2. Apply the changes listed in the batch
3. If the project mirrors or generates files from the edited sources (e.g. a packaged
   template directory, a generated schema, an embedded bundle), run the project's
   sync/build step so the mirrors stay in lock-step
4. Run the project's standard validation on anything the batch touched: linter,
   type-checker, and the test suite. Also run any format-specific sanity check that
   applies (e.g. JSON parse on config files, shellcheck on shell scripts)
5. git add -A && git commit -m "fix(<batch-name>): <one-line summary>"
6. Show a diff summary of what changed
7. Stop and wait for "next" before moving to the next batch

Absolute rules:
- Never merge or push without explicit instruction
- If a batch flags a decision to make (Option A / Option B), stop and ask before proceeding
- Never edit mirrored or generated files directly — edit the source and re-run the project's sync/build step

Start with Batch 1 now.
```

**Prompt — open PRs and merge in order**

Assumes GitHub + the `gh` CLI. Adapt the commands to your host's PR tool (`glab`, `bb`, etc.) if you use a different forge.

```
You have [N] branches ready. Open a PR for each and merge into the default branch in batch order.

For each branch:
1. git checkout <branch>
2. gh pr create --base <default-branch> --title "<conventional title>" --body "Batch [N] — /tmp/roadmap.md"
3. gh pr checks --watch
4. If CI passes: gh pr merge --squash --delete-branch
5. git checkout <default-branch> && git pull
6. Move to the next branch

Stop on red CI. Show the failure output and wait for instructions.
Do not merge out of order.

Branch order:
[numbered list in roadmap order]

Start with branch 1 now.
```

## Anti-patterns

- ❌ Starting execution before the roadmap is in `/tmp/roadmap.md` and validated
- ❌ Reading the review before reading `CLAUDE.md` — you'll flag intentional decisions as bugs
- ❌ Grouping two batches that touch the same files — conflicts compound silently
- ❌ Fixing a P3 before a P0 because it's easier
- ❌ Leaving Notes blank on a disagreement — silent dismissal is not a position
- ❌ Merging branches out of order — diffs accumulate and rebases become opaque
- ❌ Editing mirrored or generated files directly instead of the source, then re-running the project's sync/build step
- ❌ Letting a batch silently contradict another skill, rule, or agent in the repo — cross-check the change against the rest of the config before committing
- ❌ Classifying a "file X is committed / tracked / leaking into git" finding without first running the project's list-tracked-files check (e.g. `git ls-files <path>`, `git check-ignore -v <path>`). Filesystem tools like `find` / `ls` show on-disk files, not tracked files — a file can exist locally while already being ignored. Verify tracked state during Phase 1 triage, not during Phase 3 execution.