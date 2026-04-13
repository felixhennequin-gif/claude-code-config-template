---
name: banned-patterns
description: Patterns that should never appear in code — Claude must flag or refuse these. Loaded when editing JS/TS/Python source.
globs: ["**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx", "**/*.py"]
---

## Universal (all languages)

- Never commit `.env` files, API keys, tokens, or secrets to git
- Never use `console.log` / `print()` for production logging — use a structured logger
- Never catch exceptions silently (`catch {}` / `except: pass`) — at minimum, log them
- Never hardcode URLs, ports, or hostnames — use environment variables or config
- Never use `any` type in TypeScript — use `unknown` if the type is genuinely unknown
- Never use `eval()` or `exec()` in any language

## JavaScript / TypeScript

- Never use `var` — use `const` by default, `let` when reassignment is needed
- Never use `==` — always `===`
- Never use `fs.readFileSync` / `fs.writeFileSync` in server code — use async versions
- Never use `new Date()` for time comparisons across timezones — use a library (date-fns, dayjs)

## Python

- Never use mutable default arguments (`def fn(items=[])`) — use `None` and initialize inside
- Never use `import *` — always explicit imports
- Never use `os.system()` — use `subprocess.run()` with `shell=False`
- Never use bare `except:` — always catch specific exceptions
