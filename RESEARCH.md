# Research — CLAUDE.md in Open Source Repos

> Exhaustive research conducted on 2026-04-13 via Claude.ai (deep web search).
> ~55 repos/projects analyzed, 5 categories, statistical synthesis included.

This file documents the raw data behind this template's design decisions.

---

## CATEGORY A — Major companies / projects (native CLAUDE.md in repo)

| # | Repo | Org | Stars | Language | Stack | CLAUDE.md size | Key sections |
|---|---|---|---|---|---|---|---|
| 1 | `supabase/supabase-js` | Supabase | 4.3k | TypeScript | Nx monorepo, 6 SDK packages | 931 lines / 30.8 KB | Architecture, commands, TS conventions, release workflow, monorepo structure |
| 2 | `bitwarden/server` | Bitwarden | 16k+ | C# / .NET | Backend API + DB + Docker | Present (via bitwarden-init plugin) | Backend architecture, C# conventions, dotnet commands |
| 3 | `bitwarden/android` | Bitwarden | 7k+ | Kotlin | Android app | Present (PR #6368) | Kotlin conventions, MVVM architecture |
| 4 | `anthropics/claude-code-action` | Anthropic | 10k+ | TypeScript | GitHub Action | ~60 dense lines | Entrypoint, auth priority, mode lifecycle, prompt construction, gotchas |
| 5 | `vercel/next-devtools-mcp` | Vercel | Recent | TypeScript | MCP Server for Next.js | Medium | Commands (pnpm), MCP structure, testing with Agent SDK |
| 6 | `vercel-labs/agent-skills` | Vercel Labs | Recent | TypeScript | Official skills collection | Present | React best practices, web design guidelines |
| 7 | `gaearon/overreacted.io` | Dan Abramov | 7k+ | TypeScript | Blog (Next.js, React, MDX) | Concise | Style, technical depth, project personality |
| 8 | `openai/openai-agents-python` | OpenAI | 15k+ | Python | Multi-agent framework | Detailed | Agent architecture, Python conventions, testing |
| 9 | `basicmachines-co/basic-memory` | Basic Machines | 3k+ | Python | MCP + AI collaboration | Detailed | MCP integration, FastAPI patterns |
| 10 | `pydantic/genai-prices` | Pydantic | Recent | Python | AI model pricing | Concise | Data structure, conventions |

## CATEGORY B — Notable open-source projects (CLAUDE.md verified)

| # | Repo | Domain | Language | CLAUDE.md characteristics |
|---|---|---|---|---|
| 11 | `lfnovo/open-notebook` | NotebookLM alternative | Python/React | Full architecture with ASCII diagrams |
| 12 | `claudecode.nvim` | IDE Extension | Lua/TS | Strict TDD Red-Green-Refactor |
| 13 | `Claudio` | Audio hooks plugin | Go | 5-level sound fallback |
| 14 | `timothywarner-org/claude-code` | O'Reilly course | TS/Python | Commands, gotchas, MCP servers |
| 15 | `shanraisshan/claude-code-best-practice` | Best practices | Markdown | Subagent YAML spec, hooks config |
| 16 | `ChrisWiles/claude-code-showcase` | Full showcase | TypeScript | 5.2k stars, hooks + skills + agents + commands |

## CATEGORY C — Official enterprise skills (via awesome-agent-skills)

| # | Company | Published skills | Content |
|---|---|---|---|
| 17 | Cloudflare | agents-sdk, durable-objects, web-perf, wrangler + 3 more | Workers, KV, R2, D1, WebSockets |
| 18 | Netlify | netlify-functions, netlify-edge-functions, netlify-blobs | Serverless, edge, storage |
| 19 | Stripe | Skills in VoltAgent | Payment integration |
| 20 | Sentry | Official Anthropic marketplace plugin | Error monitoring |
| 21-29 | Expo, Hugging Face, Figma, Google Labs, Google Workspace, Microsoft, Supabase, Trail of Bits, Remotion | Various | See full research |

## CATEGORY D — Community projects (indexed by awesome-claude-md)

Projects 30-47: Aider, LangChain, Pydantic AI, FastHTML, Tauri, Deno, SWC, Zed Editor, Neon, Turborepo, Effect-TS, Hono, tRPC, Solid.js, Astro, Svelte, and others.

Note: sourced from `josix/awesome-claude-md` which may be ~2 months behind. Individual verification not performed.

## CATEGORY E — Reusable templates

| # | Repo | Stars | Provides |
|---|---|---|---|
| 50 | `abhishekray07/claude-md-templates` | ~200 | Templates by stack, 3-level hierarchy |
| 51 | `ChrisWiles/claude-code-showcase` | 5.2k | Complete showcase with all components |
| 52 | `centminmod/my-claude-code-setup` | ~100 | Memory bank system, 20+ commands |
| 53 | `Matt-Dionis/claude-code-configs` | ~100 | Config composer CLI, 15 agents |
| 54 | `bitwarden/ai-plugins` | ~50 | Full Bitwarden marketplace |

---

## Statistical synthesis

### Most frequent CLAUDE.md sections

| Section | Frequency |
|---|---|
| Build/test/lint commands | ~95% |
| Repo structure / Architecture | ~90% |
| Stack / Technologies | ~85% |
| Code conventions | ~80% |
| Project description (one-liner) | ~70% |
| Git / PR workflow | ~60% |
| References to other docs | ~55% |
| **Gotchas / Known pitfalls** | **~35% (underused, highest ROI)** |
| Dependencies / Local setup | ~30% |
| Code examples | ~20% |
| ASCII diagrams | ~15% |

### CLAUDE.md sizes

| Category | Proportion |
|---|---|
| Compact (<50 lines) | 30% |
| **Standard (50-150 lines)** | **45% (sweet spot)** |
| Detailed (150-400 lines) | 20% |
| Exhaustive (400+ lines) | 5% |

### Most advanced adopters

1. **Bitwarden** — dedicated plugin marketplace, auto-generates CLAUDE.md
2. **Supabase** — 931-line CLAUDE.md, published postgres skills
3. **Vercel** — CLAUDE.md in next-devtools-mcp, React/Web design skills
4. **Anthropic** — CLAUDE.md in claude-code-action, official plugins
5. **Cloudflare** — 6 official skills covering entire Workers ecosystem
6. **OpenAI** — CLAUDE.md in openai-agents-python
