# Context budget guide

Every file in `.claude/` costs tokens. Here's how to keep the cost under control.

## Highest-ROI move: ship a `.claudeignore`

Before you start pruning skills, ship `template/.claudeignore` into your project root. Without it, Claude will happily pull `node_modules/`, `dist/`, `package-lock.json`, coverage reports, and minified bundles into context — easily tens of thousands of tokens of noise per session. A one-file ignore list saves more tokens than pruning every optional skill combined. This is the single highest-ROI token-saving measure in this template.

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

## How to estimate

Claude Code doesn't expose exact token counts, but you can estimate:

1. **File size rule of thumb**: ~1.3 tokens per word, ~0.4 tokens per character. An 80-line CLAUDE.md with ~40 chars/line ≈ 80 × 40 × 0.4 ≈ 1,280 tokens.
2. **Check what's loaded**: At the start of a session, ask Claude "What files from .claude/ are currently in your context?" — it will list what it loaded.
3. **Compare sessions**: Run the same task with and without a specific skill. If Claude follows the skill's conventions only when it's present, it's being loaded. If it follows them either way, the skill is redundant (Claude already knows the pattern from training).
