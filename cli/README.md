# create-claude-code-config

Interactive CLI to scaffold a [Claude Code](https://docs.anthropic.com/en/docs/claude-code) config for any project.

Part of [claude-code-config-template](https://github.com/felixhennequin-gif/claude-code-config-template).

## Usage

```bash
npx create-claude-code-config
```

Or with npm create:

```bash
npm create claude-config
```

## What it does

1. Asks for your project directory
2. Lets you pick stack skills (Express, Prisma, React, FastAPI — or core only)
3. Copies `CLAUDE.md`, `.claude/` (hooks, commands, rules, skills), and `CLAUDE.local.md`
4. Adds `.gitignore` entries for personal files
5. Removes unselected stack skills

No runtime dependencies in your project — it just copies files.

## Options

No flags needed — the CLI is fully interactive. Pass `--help` for usage info.

## License

MIT
