# Cost comparison logs

This directory holds raw, side-by-side logs of identical workflows run with and without the Haiku worker sub-agents (`pr-creator`, `commit-writer`, `changelog-updater`) and the `/pr` orchestration command.

The point is not a synthetic benchmark — it is reproducible evidence that the model-tiering pattern shipped in this template (reasoning model orchestrates, Haiku does grunt work) costs measurably less than letting the reasoning model do everything end-to-end.

## What goes in here

One subdirectory per scenario, each containing two files:

```
examples/cost-comparison/
├── pr-creation/
│   ├── with-workers.md       # /pr delegating to Haiku sub-agents
│   └── without-workers.md    # same task, single reasoning-model invocation
├── changelog-update/
│   ├── with-workers.md
│   └── without-workers.md
└── ...
```

## Format for each log

Each `.md` file is a faithful capture of one Claude Code run. Use this template:

```markdown
# <scenario>: <variant>

- **Date**: <YYYY-MM-DD>
- **Project**: <name + commit SHA the run was made against>
- **Model (orchestrator)**: <e.g. claude-opus-4-7>
- **Models (sub-agents)**: <e.g. pr-creator → claude-haiku-4-5-20251001>
- **Claude Code version**: <e.g. 1.x.x>
- **Task**: <one-line description of what was asked>

## Verbatim transcript

<paste the full stdout from the Claude Code run, unedited>

## Token usage

| Stage | Input tokens | Output tokens | Cost (USD) |
|---|---|---|---|
| Orchestrator | … | … | … |
| commit-writer | … | … | … |
| pr-creator | … | … | … |
| **Total** | … | … | … |

## Wall clock

<duration in seconds>

## Notes

<anything that would help a reader interpret the result — e.g. "the orchestrator made one extra clarification round", "Haiku miscategorized a fix as a feat once and was corrected">
```

## Rules for the logs to be credible

- **Same task, same project, same git SHA** for both variants. If the second run is on a slightly different state, the comparison is meaningless.
- **Don't curate the transcript.** Paste raw stdout. If the orchestrator made a mistake or the worker stalled, that is part of the data.
- **Token counts come from a real source** — Anthropic API usage, Claude Code's own usage telemetry, or `/cost` output if the CLI exposes it. Don't estimate.
- **One run per file.** If you re-run the scenario, add a second file (e.g. `with-workers-2.md`) rather than overwriting.

## Why side-by-side and not a synthetic benchmark

Synthetic benchmarks invite "but my prompt is different" objections. Two real transcripts of the same task on the same project shut down that objection — anyone can run the same workflow on their own project and check.

## Status

Empty — to be populated. The first scenarios planned:

- [ ] `pr-creation/` — opening a PR for a small feature branch (≈10 files, ≈200 lines diff)
- [ ] `commit-message/` — drafting a Conventional Commits message for a security fix vs a refactor
- [ ] `changelog-update/` — appending entries for a batch of merged PRs

Once at least one scenario is filled in, `README.md` (project root) gains a "Model tiering" section that cites these numbers.
