# Research notes

> Analysis conducted: March–April 2026. Repo states may have changed since.

What we learned from analyzing notable open-source Claude Code configurations. This is not a comprehensive survey — it's the patterns and anti-patterns that shaped this template's design.

## Key findings

### 1. CLAUDE.md length matters — but not the way you think

Most repos with a CLAUDE.md over 100 lines showed evidence of Claude ignoring later sections. The best-performing configs (Supabase, Anthropic's own claude-code-action) kept their root CLAUDE.md under 60 lines and offloaded details to skills and docs.

**Template decision:** 80-line soft limit for project CLAUDE.md.

### 2. Skills beat inline instructions

Repos that used `.claude/skills/` with proper frontmatter (triggers, description) had more consistent Claude behavior than repos that put everything in CLAUDE.md. The trigger mechanism means skills only load when relevant — they don't compete for context.

**Template decision:** Core behavioral rules in a skill, not in CLAUDE.md.

### 3. Hooks are underused

Only ~15% of repos we found used hooks at all. The ones that did (Supabase, ChrisWiles/showcase) used them for branch protection and auto-formatting — deterministic, zero-token-cost automation. Nobody was using SessionStart hooks for dynamic context injection, which is a missed opportunity.

**Template decision:** Ship branch guard + lint hook + SessionStart hook + Bash safety hook.

### 4. Agents need to be project-specific

Generic agents ("review this code", "audit security") performed poorly unless they included project-specific context (stack, conventions, known issues). The best agent configs we found (Bitwarden, Vercel) were tightly coupled to their stack.

**Template decision:** Ship agents as examples, not defaults. Users copy and customize.

### 5. Stack-specific rules mixed with universal rules cause confusion

Repos that mixed "use Prisma's `include` for eager loading" next to "keep functions under 50 lines" in the same file created inconsistent Claude behavior — Claude would apply stack rules to the wrong files.

**Template decision:** `core/` for universal, `stacks/` for framework-specific, loaded separately.

### 6. Most repos don't survive 3 months

The majority of community template repos we looked at had no commits in the last 30 days. The ones that survived were either backed by a company (Supabase, Cloudflare) or had a CLI/automation layer that made updates easy. Pure-template repos rot fast.

**Template decision:** Keep the template small and opinionated. Don't try to cover every stack — cover the pattern well and let users adapt.

## Anti-patterns we avoided

- **The 500-line CLAUDE.md** — Several repos had massive root files. Claude visibly ignored the bottom half.
- **Skills without triggers** — Some repos had skills that activated on "every file." This defeats the purpose of the skill system.
- **Hooks that require specific tools** — Relying on `jq` being installed broke in clean CI environments. We use a jq→node fallback.
- **Agent frontmatter tool permissions** — Some repos put `tools: Bash(*)` in agent files. This isn't how Claude Code enforces permissions — `settings.json` is the source of truth.

## Sources

The repos that most influenced this template's design:

| Repo | What we took from it |
|------|---------------------|
| Supabase (supabase-js) | CLAUDE.md structure, line discipline |
| Anthropic (claude-code-action) | Minimal root config, skill-first approach |
| Cloudflare (6 skills) | Skill frontmatter conventions, trigger patterns |
| Bitwarden (server, android) | Agent specialization, stack-coupling |
| ChrisWiles/claude-code-showcase | Hook patterns, SessionStart idea |
| Vercel (agent-skills) | Skill organization, naming conventions |

## Repos that most directly shaped the template

<details>
<summary>Click to expand — organized by category. Not all repos are still active or still have a <code>.claude/</code> directory.</summary>

**Company-backed projects**
- supabase/supabase-js
- anthropics/claude-code-action
- cloudflare/workers-sdk (and other Cloudflare repos shipping skills)
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

</details>

Individual project configs found via GitHub search for `CLAUDE.md` + `.claude/` also informed the anti-patterns list, but aren't enumerated here — we'd rather be honest than pad the list with repos we can no longer verify. If you know a config that deserves a mention, open an issue or PR.
