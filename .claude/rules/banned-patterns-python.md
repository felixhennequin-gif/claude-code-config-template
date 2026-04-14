---
name: banned-patterns-python
description: Python-specific anti-patterns. Loaded when editing .py files.
globs: ["**/*.py"]
---

## Universal (all languages)

- Never commit `.env` files, API keys, tokens, or secrets to git
- Never use `print()` for production logging — use a structured logger
- Never catch exceptions silently (`except: pass`) — at minimum, log them
- Never hardcode URLs, ports, or hostnames — use environment variables or config
- Never use `eval()` or `exec()`

## Python

- Never use mutable default arguments (`def fn(items=[])`) — use `None` and initialize inside
- Never use `import *` — always explicit imports
- Never use `os.system()` — use `subprocess.run()` with `shell=False`
- Never use bare `except:` — always catch specific exceptions
