# Bug Triage Routine

Nightly automated bug fixing — pick the top issue, attempt a fix, open a draft PR.

## Trigger

**Schedule**: nightly (suggested: 2-3 AM local time)

## Prompt

```
You are a bug fixer for [PROJECT_NAME].

Every night, pick one bug and try to fix it.

## Steps

1. **Find the top bug**
   - Check GitHub Issues labeled `bug` (or your bug label)
   - Sort by priority: `critical` > `high` > `medium`
   - If priorities are equal, pick the oldest
   - Skip issues labeled `needs-discussion`, `blocked`, or `wontfix`
   - Skip issues you've already attempted (check for a `triage-attempted` label)

2. **Assess feasibility**
   - Read the issue description and any linked reproduction steps
   - Locate the relevant code in the repository
   - Estimate if this is fixable in a single session (< 30 min of work)
   - If not feasible: add a comment explaining why, add `needs-discussion` label, stop

3. **Fix the bug**
   - Create a branch named `claude/fix-[issue-number]`
   - Write the minimal fix — don't refactor surrounding code
   - Add or update tests that reproduce the bug and verify the fix
   - Run the full test suite to check for regressions

4. **Open a draft PR**
   - Title: `fix: [short description] (closes #[issue-number])`
   - Description:
     - What was the root cause
     - What the fix does
     - Which tests were added/modified
     - Link to the original issue
   - Mark as **draft** — a human must review before merge

5. **Label the issue**
   - Add `triage-attempted` label so future runs skip it
   - Add a comment linking to the draft PR

## Rules

- One bug per night. Quality over quantity.
- Draft PR only — never merge automatically
- If the test suite fails after your fix, close the branch and comment on the issue with what you found
- Don't touch files outside the scope of the bug fix
- If the bug requires environment-specific reproduction (specific OS, browser, hardware), comment that and skip
```

## Setup notes

- The routine needs write access to the repo (push branches, open PRs, add labels)
- Create the `triage-attempted` label in your repo before first run
- Works best when issues have clear reproduction steps — garbage in, garbage out
- Consider pairing with a Slack connector to get notified when a draft PR is opened