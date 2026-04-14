# Research notes

> This is not a formal study. These are observations from reviewing notable open-source Claude Code configurations that shaped this template's design decisions.

## Key findings

### 1. CLAUDE.md length matters — but not the way you think

Long root `CLAUDE.md` files (well over 100 lines) showed the same failure mode across repos: Claude quietly drops the tail. The configs that felt best to work with kept the root file short and offloaded detail to skills and docs.

**Template decision:** 80-line soft limit for project CLAUDE.md.

### 2. Skills beat inline instructions

Repos that used `.claude/skills/` with proper frontmatter (triggers, description) had more consistent Claude behavior than repos that put everything in CLAUDE.md. The trigger mechanism means skills only load when relevant — they don't compete for context.

**Template decision:** Core behavioral rules in a skill, not in CLAUDE.md.

### 3. Hooks are underused

Most configs we looked at used no hooks at all. The few that did used them for branch protection and auto-formatting — deterministic, zero-token-cost automation. Almost nobody was using `SessionStart` for dynamic context injection, which is a missed opportunity.

**Template decision:** Ship branch guard + lint hook + `SessionStart` + bash-safety hook, and an opt-in `UserPromptSubmit` example.

### 4. Agents need to be project-specific

Generic agents ("review this code", "audit security") performed poorly unless they included project-specific context (stack, conventions, known issues). The best agent configs we found were tightly coupled to their stack.

**Template decision:** Ship agents as examples, not defaults. Users copy and customize.

### 5. Stack-specific rules mixed with universal rules cause confusion

Repos that put "use Prisma's `include` for eager loading" next to "keep functions under 50 lines" in the same file produced inconsistent Claude behavior — stack rules sometimes bled into the wrong files.

**Template decision:** `core/` for universal, `stacks/` for framework-specific, loaded separately.

### 6. Pure-template repos rot fast

Community template repos with no company backing and no automation layer go stale quickly — many we looked at had no commits in the last month. The survivors were either company-owned or had a CLI that made updates easy.

**Template decision:** Keep the template small and opinionated. Don't try to cover every stack — cover the pattern well and let users adapt.

## Anti-patterns we avoided

- **The 500-line CLAUDE.md** — Claude visibly ignored the bottom half.
- **Skills without triggers** — activating on "every file" defeats the point of the skill system.
- **Hooks that require specific tools** — hard dependencies on tools like `jq` broke in clean CI environments. We use a jq→node fallback.
- **`Bash(*)` wildcard in agent frontmatter `tools:`** — the scoped `tools:` field is fine and useful for read-only agents, but a `Bash(*)` entry defeats the purpose. `.claude/settings.json` remains the source of truth for the permission ceiling; frontmatter `tools:` can only narrow it.

## Sources

The repos that most directly shaped this template:

| Repo | What we took from it |
|------|---------------------|
| Supabase (supabase-js) | CLAUDE.md structure, line discipline |
| Anthropic (claude-code-action) | Minimal root config, skill-first approach |
| Cloudflare (6 skills) | Skill frontmatter conventions, trigger patterns |
| Bitwarden (server, android) | Agent specialization, stack-coupling |
| ChrisWiles/claude-code-showcase | Hook patterns, SessionStart idea |
| Vercel (agent-skills) | Skill organization, naming conventions |

<details>
<summary>Repos consulted (click to expand)</summary>

**Company-backed projects**
- supabase/supabase-js
- anthropics/claude-code-action
- cloudflare/workers-sdk
- bitwarden/server
- bitwarden/android
- bitwarden/ai-plugins
- vercel/next-devtools-mcp
- vercel/agent-skills
- openai/openai-agents-python

**Community templates & tools**
- ChrisWiles/claude-code-showcase
- davila7/claude-code-templates
- abhishekray07/claude-md-templates
- serpro69/claude-toolbox
- midudev/autoskills
- forrestchang/andrej-karpathy-skills

If a config you think deserves a mention is missing, open an issue or PR.

</details>
