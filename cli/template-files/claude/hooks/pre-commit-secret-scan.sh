#!/usr/bin/env bash
# PreToolUse hook on Bash: scan tracked changes for known credential patterns
# and block .env file commits before `git commit` runs. Token-free, fail-open
# on parse errors (the dangerous-rm-guard hook is the fail-closed line).
#
# Triggered by .claude/settings.json on every Bash call. The hook filters
# internally to only act on `git commit` invocations — other commands pass
# through silently with exit 0.

set -u

INPUT=$(cat)

# Parse tool_input.command — jq with node fallback (mirrors lint-on-edit.sh).
if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
else
  CMD=$(printf '%s' "$INPUT" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{process.stdout.write(JSON.parse(s).tool_input.command||"")}catch(e){}})' 2>/dev/null)
fi

# Pass through if not a git commit invocation.
case "$CMD" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

# Scope: HEAD vs working tree covers both staged and `-a` commits in one shot.
# Falls back to --cached for the first-commit case where HEAD does not exist.
DIFF=$(git diff HEAD 2>/dev/null || git diff --cached 2>/dev/null || true)
NAMES=$(git diff HEAD --name-only 2>/dev/null || git diff --cached --name-only 2>/dev/null || true)

# Block any .env file unless it is a documented template.
ENV_FILES=$(printf '%s\n' "$NAMES" | grep -E '(^|/)\.env(\..*)?$' | grep -vE '\.(example|sample|template)$' || true)
if [ -n "$ENV_FILES" ]; then
  cat >&2 <<EOF
Blocked: .env file(s) about to be committed:
$ENV_FILES
Add to .gitignore and remove from the index:
  git rm --cached <file>
EOF
  exit 2
fi

# High-confidence credential patterns. Conservative on purpose — only formats
# that are unambiguously credentials, never plain SECRET=... or generic base64.
PATTERNS=(
  'AKIA[0-9A-Z]{16}'
  'ghp_[A-Za-z0-9]{36}'
  'gho_[A-Za-z0-9]{36}'
  'ghs_[A-Za-z0-9]{36}'
  'github_pat_[A-Za-z0-9_]{60,}'
  'sk_live_[A-Za-z0-9]{24,}'
  'xox[baprs]-[A-Za-z0-9-]{10,}'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
)

FOUND=""
for P in "${PATTERNS[@]}"; do
  if printf '%s' "$DIFF" | grep -qE -- "$P"; then
    FOUND="$FOUND
  - matched pattern: $P"
  fi
done

if [ -n "$FOUND" ]; then
  cat >&2 <<EOF
Blocked: tracked changes appear to contain credentials.$FOUND

Unstage the offending file:
  git restore --staged <file>     # if staged
  git checkout -- <file>          # if unstaged tracked change
Move the value to an environment variable or a gitignored config file.
EOF
  exit 2
fi

exit 0
