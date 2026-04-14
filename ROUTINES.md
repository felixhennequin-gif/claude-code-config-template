# Routines

> Cloud-based automations that run on Anthropic's infrastructure — your machine doesn't need to be on.

Routines are a [research preview feature](https://code.claude.com/docs/en/routines) launched April 2026. They package a prompt + repos + connectors and execute on three trigger types:

- **Schedule** — cron in the cloud (hourly, daily, weekly)
- **API** — POST to a dedicated endpoint with a bearer token
- **GitHub** — react to PR opens, pushes, issues, workflow runs, etc.

## How routines differ from hooks

| | Hooks | Routines |
|---|---|---|
| **Runs where** | Your machine (shell commands) | Anthropic cloud |
| **Triggered by** | Claude Code lifecycle events | Schedule, API call, GitHub webhook |
| **Needs machine on** | Yes | No |
| **Token cost** | Zero (deterministic) | Same as interactive sessions |
| **Best for** | Formatting, blocking, logging | Review, triage, deploy checks |

Use hooks for deterministic guardrails (block `main`, auto-lint). Use routines for judgment-based automation (review PRs, triage bugs, verify deploys).

## Available routine examples

This template ships ready-to-use routine prompts under `routines/`. Each file contains the prompt, recommended trigger, and setup instructions.

| Routine | Trigger | Description |
|---|---|---|
| [`pr-review.md`](routines/pr-review.md) | GitHub: `pull_request.opened` | Code review against project conventions |
| [`dependency-audit.md`](routines/dependency-audit.md) | Schedule: weekly | Check outdated deps + security vulnerabilities |
| [`deploy-verify.md`](routines/deploy-verify.md) | API: post-deploy | Smoke test endpoints + check logs for errors |
| [`bug-triage.md`](routines/bug-triage.md) | Schedule: nightly | Pick top bug, attempt fix, open draft PR |
| [`docs-drift.md`](routines/docs-drift.md) | Schedule: weekly | Detect stale docs after API/schema changes |

## Setup

### From the web

1. Go to [claude.ai/code/routines](https://claude.ai/code/routines)
2. Click **New routine**
3. Copy the prompt from the routine file you want
4. Select your repo and trigger type
5. Configure connectors (Slack, Linear, etc.) if the routine mentions them

### From the CLI

```bash
# Create a scheduled routine conversationally
/schedule

# Or with a description
/schedule "nightly bug triage at 2am"

# List existing routines
/schedule list
```

### Limits

| Plan | Daily runs |
|---|---|
| Pro | 5 |
| Max | 15 |
| Team / Enterprise | 25 |

Runs consume the same quota as interactive sessions.

## Customizing prompts

Each routine prompt is self-contained. Adapt it by:

1. Replacing `[placeholder]` values with your project specifics
2. Adding or removing checklist items
3. Adjusting the output format (PR comments, Slack messages, issues)

Keep prompts explicit about **what success looks like** — routines run unattended, so ambiguity = wasted runs.

## References

- [Official routines docs](https://code.claude.com/docs/en/routines)
- [Cloud environments](https://code.claude.com/docs/en/claude-code-on-the-web#the-cloud-environment)
- [MCP connectors](https://code.claude.com/docs/en/mcp)