---
name: code-review
description: Structured workflow for acting on an external code review — triage findings by severity and effort, write a prioritized roadmap to /tmp/roadmap.md, then hand execution prompts to Claude Code batch by batch. Activates when the user receives a review, audit, or critique of their repo and wants to act on it. Also triggers on "triage this review", "make a roadmap from this feedback", "act on these findings", "we have a list of issues to fix".
---

<!-- Workflow extracted from a real review session on claude-code-config-template v0.9.5.
     Three phases: Analyse → Roadmap → Execute. Never collapse them into one. -->

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
- It is already addressed in `CHANGELOG.md`

## 2. Write the roadmap

Group findings into batches. One batch = one branch + one PR. Then write everything to `/tmp/roadmap.md` and stop.

**Grouping rules**
- P0 always goes first, alone or with adjacent S-effort items
- Group by file proximity — avoid two batches touching the same files
- P1 effort S before P1 effort L (quick wins before big refactors)
- P2 and P3 go last or are deferred with justification

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
## Batch 3 — fix/audit-grep-dotenv
**P1 — ~20 min**
Fix secret scan in audit.md that misses plain .env files (no extension).

- [ ] Replace --include="*.env*" with two patterns: --include=".env" and --include="*.env*"
- [ ] Align with the stricter regex already used in .github/workflows/lint.yml
- [ ] Run bash cli/sync-templates.sh to propagate the change to cli/template-files/
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
3. If a sync script exists (e.g. bash cli/sync-templates.sh), run it after any batch
   that touches source files copied elsewhere in the repo
4. Validate: python3 -m json.tool .claude/settings.json > /dev/null if settings.json
   was touched; shellcheck -S error .claude/hooks/*.sh if a hook was touched
5. git add -A && git commit -m "fix(<batch-name>): <one-line summary>"
6. Show a diff summary of what changed
7. Stop and wait for "next" before moving to the next batch

Absolute rules:
- Never merge or push without explicit instruction
- If a batch flags a decision to make (Option A / Option B), stop and ask before proceeding
- Never edit cli/template-files/ directly — edit the source then run the sync script

Start with Batch 1 now.
```

**Prompt — open PRs and merge in order**

```
You have [N] branches ready. Open a PR for each and merge into master in batch order.

For each branch:
1. git checkout <branch>
2. gh pr create --base master --title "<conventional title>" --body "Batch [N] — /tmp/roadmap.md"
3. gh pr checks --watch
4. If CI passes: gh pr merge --squash --delete-branch
5. git checkout master && git pull
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
- ❌ Editing `cli/template-files/` directly instead of the source file