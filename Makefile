.PHONY: help lint test-hooks sync check

help:
	@echo "Targets:"
	@echo "  make lint        Run the same static checks as CI (JSON, shellcheck, frontmatter)"
	@echo "  make test-hooks  Smoke-test hooks (dangerous-rm-guard + branch guard)"
	@echo "  make sync        Re-sync cli/template-files/ from source"
	@echo "  make check       lint + test-hooks (run before committing)"

lint:
	@echo "==> Validate settings.json"
	@python3 -m json.tool .claude/settings.json > /dev/null
	@echo "==> Shellcheck hook scripts"
	@if command -v shellcheck > /dev/null; then shellcheck -S error .claude/hooks/*.sh; else echo "shellcheck not installed — skipping (CI will run it)"; fi
	@echo "==> Validate frontmatter (skills, agents, rules)"
	@set -e; \
	for f in $$(find .claude/skills -name SKILL.md); do \
	  awk 'BEGIN{c=0} /^---$$/{c++; if(c==2) exit; next} c==1' "$$f" | grep -q '^name:' \
	    || { echo "::error $$f missing name"; exit 1; }; \
	  awk 'BEGIN{c=0} /^---$$/{c++; if(c==2) exit; next} c==1' "$$f" | grep -q '^description:' \
	    || { echo "::error $$f missing description"; exit 1; }; \
	done
	@echo "==> Validate skill body sections (Anti-patterns required)"
	@set -e; \
	for f in $$(find .claude/skills -name SKILL.md); do \
	  grep -qE '^## Anti-patterns' "$$f" \
	    || { echo "::error $$f missing '## Anti-patterns' section"; exit 1; }; \
	done
	@echo "==> Check internal markdown links"
	@python3 scripts/check-links.py
	@echo "==> Check stack skill freshness (warning-only)"
	@python3 scripts/check-skill-freshness.py
	@echo "==> Check CLI template sync"
	@bash cli/sync-templates.sh > /dev/null
	@git diff --quiet cli/template-files/ || { echo "::error cli/template-files/ out of sync — run 'make sync' and commit"; exit 1; }
	@echo "OK"

test-hooks:
	@echo "==> dangerous-rm-guard (should PASS)"
	@echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf ./dist"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@echo '{"tool_name":"Bash","tool_input":{"command":"git push --force-with-lease origin main"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@echo '{"tool_name":"Bash","tool_input":{"command":"npm publish --dry-run"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@echo "==> dangerous-rm-guard (should BLOCK)"
	@! echo '{"tool_name":"Bash","tool_input":{"command":"rm -rf /"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@! echo '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@! echo '{"tool_name":"Bash","tool_input":{"command":"npm publish"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@! echo '{"tool_name":"Bash","tool_input":{"command":"dd if=/dev/zero of=/dev/sda"}}' | bash .claude/hooks/dangerous-rm-guard.sh
	@! echo 'not json at all' | bash .claude/hooks/dangerous-rm-guard.sh
	@echo "OK"

sync:
	@bash cli/sync-templates.sh

check: lint test-hooks
	@echo "All checks passed."
