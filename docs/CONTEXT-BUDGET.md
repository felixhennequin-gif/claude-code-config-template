# Context budget guide

Every file in `.claude/` costs tokens. Here's how to keep the cost under control.

## Estimated token costs

| Component | Approx. tokens | Loaded when |
|-----------|---------------|-------------|
| CLAUDE.md (80 lines) | ~800 | Every session |
| coding-principles skill | ~400 | Every code edit |
| One stack skill | ~600 | When trigger matches |
| One agent | ~500 | When invoked |
| One command | ~300 | When invoked |
| Hooks | 0 | Never (shell only) |
| Rules | ~100 each | When matching file is edited |

## Budget profiles

### Minimal (~1,200 tokens/session)
- CLAUDE.md + coding-principles only
- Delete `.claude/skills/stacks/` entirely
- No agents, no commands
- Best for: small scripts, personal projects, non-Node stacks without a custom skill

### Standard (~2,400 tokens/session)
- CLAUDE.md + coding-principles + 1-2 stack skills
- Commands available on demand
- Best for: typical web projects

### Full (~4,000 tokens/session)
- Everything included
- All stack skills + custom agents
- Best for: large projects where every convention matters

## Rules of thumb

1. If you're not using a stack skill's framework, delete it — it's pure noise
2. Agents only load when you invoke them — don't worry about their cost during normal coding
3. Commands only load when you type the slash command — same as agents
4. The coding-principles skill is the one you should almost never delete — it's the highest-ROI file
5. If your CLAUDE.md is over 80 lines, you're probably duplicating what a skill already covers

## How to measure

Ask Claude Code: "How many tokens is my current context?" at the start of a session. Compare with and without specific skills to see their real cost.
