# Hacking on this repo

Detailed notes for contributors working *on* `claude-code-config-template`. The root `CLAUDE.md` points here for anything that doesn't fit inside its 80-line ceiling.

## CLI (`cli/`)

The `create-claude-code-config` npm package lives under `cli/`. It's published independently but shares this repo.

- Entry point: `cli/bin/create-claude-code-config.js`
- Template files are embedded in `cli/template-files/` — copies of `template/` and `.claude/`
- After any change to template files, skills, hooks, rules, or commands: run `bash cli/sync-templates.sh` to re-copy them into `cli/template-files/`
- CI fails if `cli/template-files/` diverges from the source files
- The CLI has one dependency: `prompts`
- Test locally with `cd cli && node bin/create-claude-code-config.js`

## `make check` targets

`make check` is the one-command local equivalent of CI. It wraps these individual targets, which you can also run on their own when iterating:

- `make lint` — validate `settings.json`, syntax-check hooks, check frontmatter, check registry, check CLI sync
- `make test-hooks` — run the hook smoke tests below
- `make sync` — run `bash cli/sync-templates.sh`

## Raw reference commands

Kept here in case you need to run one step in isolation or CI ever drifts from the `Makefile`.

```bash
# Validate settings.json
python3 -c "import json; json.load(open('.claude/settings.json'))"

# Syntax-check hooks
bash -n .claude/hooks/lint-on-edit.sh .claude/hooks/session-start.sh .claude/hooks/dangerous-rm-guard.sh

# Smoke-test the lint hook with a sample payload
echo '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/x.js"}}' | bash .claude/hooks/lint-on-edit.sh
```

## `dangerous-rm-guard.sh` smoke tests

Every case below must produce the expected exit code. Re-run before **any** pattern addition — `grep -qF` is literal-match by design, so regex escapes silently fail.

```bash
# Should PASS (exit 0) — routine dev commands that previously false-positived:
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ./dist"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ./node_modules"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf .cache"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force-with-lease origin main"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"npm publish --dry-run"}}' | bash .claude/hooks/dangerous-rm-guard.sh

# Should BLOCK (exit 2) — genuinely dangerous:
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ~"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ."}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"git push -f origin main"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"npm publish"}}' | bash .claude/hooks/dangerous-rm-guard.sh
echo '{"tool_name":"Bash","tool_input":{"command":"dd if=/dev/zero of=/dev/sda"}}' | bash .claude/hooks/dangerous-rm-guard.sh

# Should BLOCK (exit 2) — fail-closed on unparseable input:
echo 'not json at all' | bash .claude/hooks/dangerous-rm-guard.sh
echo '' | bash .claude/hooks/dangerous-rm-guard.sh
```
