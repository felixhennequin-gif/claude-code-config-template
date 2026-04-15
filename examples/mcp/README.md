# MCP server configuration example

Claude Code reads `.mcp.json` from the project root (not from `.claude/`). This directory ships a reference config showing three common servers: `github`, `filesystem`, and `postgres`. Copy the file to your project root and adjust the server list.

## Install

```bash
cp examples/mcp/.mcp.json your-project/.mcp.json
# then edit the server list and env references
```

## Environment variables

The example references shell variables with `${VAR}` syntax:

- `GITHUB_TOKEN` — a GitHub PAT with the scopes the server needs (repo, read:org, etc.). Create one at https://github.com/settings/tokens and export it from your shell, not from a committed file.
- `PROJECT_ROOT` — absolute path of the project the filesystem server should expose. Usually `$(pwd)` at the moment you launch Claude Code.
- `DATABASE_URL` — the Postgres connection string the `postgres` server connects with. Strongly prefer a read-only user; the MCP server runs arbitrary SQL on Claude's behalf.

Never commit real tokens or connection strings — `.mcp.json` is tracked, the secrets are not. If your shell doesn't export the variables automatically, add them to `~/.profile` or your project's `.envrc` (direnv).

## Choosing servers

Install only the servers your workflow actually needs:

- **`github`** — for projects that live on GitHub and where you want Claude to read issues, PRs, and release notes without leaving the session.
- **`filesystem`** — when you want Claude to read files outside the current working directory (multi-repo setups, sibling doc repos). Skip it for single-repo work; Claude Code already has filesystem access inside the project.
- **`postgres`** — when the task genuinely needs schema introspection or query execution. Read-only users only. Do not point it at a production database.

See the [Anthropic MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp) for the full server catalog and for the exact spawn semantics (Claude Code launches servers as subprocesses and speaks JSON-RPC over stdio).

## Gotchas

- **`.mcp.json` lives at the project root, not under `.claude/`.** The CLI does not copy this file — it's yours to create per project.
- **Server packages are fetched at runtime** via `npx -y`. First-session startup is slow; subsequent sessions use the npm cache.
- **MCP tools count toward your permission ceiling.** If you want to restrict the github server to read operations only, scope its tools in `.claude/settings.json` with `mcp__github__*` entries.
- **Postgres server permissions.** Use a read-only role unless you've thought hard about the blast radius — the server will happily run `DROP TABLE` if the connection allows it.
