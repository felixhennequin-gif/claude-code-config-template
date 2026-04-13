# Examples

Ready-to-adapt `CLAUDE.md` files for common stacks. Each one is deliberately under ~80 lines — Claude Code drops context beyond that.

## Using an example

Pick the closest fit, copy it to your project root as `CLAUDE.md`, and edit the placeholders:

```bash
cp examples/express-api.CLAUDE.md /path/to/your-project/CLAUDE.md
```

Then:

1. Replace the stack versions with the ones you actually run.
2. Prune any section that doesn't apply to your project.
3. Fill in the **Gotchas** section — this is the highest-ROI part for Claude and is almost always empty in first drafts.
4. Point the **References** at real files in your repo.

## Available examples

| File | Stack | Best for |
|---|---|---|
| [`express-api.CLAUDE.md`](./express-api.CLAUDE.md) | Node.js 22, Express 5, Prisma 7, PostgreSQL, Zod, JWT | Backend-only REST APIs |
| [`nextjs-fullstack.CLAUDE.md`](./nextjs-fullstack.CLAUDE.md) | Next.js 15 App Router, Prisma 7, Tailwind v4, Auth.js | Fullstack web apps deployed to Vercel |

## Contributing a new example

See [`CONTRIBUTING.md`](../CONTRIBUTING.md). In short:

- Anonymize everything — no real IPs, domains, hostnames, personal names, or business data.
- Keep it under ~80 lines.
- Include a **Gotchas** section with at least one concrete, stack-specific pitfall.
- Name the file `<stack>.CLAUDE.md`.
